use account_sdk::account::outside_execution::OutsideExecutionAccount;
use account_sdk::account::session::account::SessionAccount as SdkSessionAccount;
use account_sdk::provider::{CartridgeJsonRpcProvider, CartridgeProvider};
use chrono::Utc;
use reqwest::StatusCode;
use serde::{Deserialize, Serialize};
use starknet::accounts::{Account, ConnectedAccount};
use starknet::core::types::Felt;
use starknet::core::utils::cairo_short_string_to_felt;
use starknet::macros::short_string;
use starknet_signers::SigningKey;
use std::sync::{Arc, Mutex};
use std::time::Duration;
use url::Url;

use crate::error::ControllerError;
use crate::runtime::RUNTIME;
use crate::types::{canonicalize_session_policies, Call, ControllerFieldElement, SessionPolicies};

#[derive(Serialize)]
struct SessionRegistrationPolicyPayload {
    target: String,
    method: String,
}

#[derive(Serialize)]
struct ShortenRequest<'a> {
    url: &'a str,
}

#[derive(Deserialize)]
struct ShortenResponse {
    url: String,
}

const CARTRIDGE_API_BASE_URL: &str = "https://api.cartridge.gg";
const KEYCHAIN_BASE_URL: &str = "https://x.cartridge.gg";

fn build_session_registration_long_url(
    public_key: &str,
    policies: &SessionPolicies,
    rpc_url: &str,
    keychain_url: &str,
    preset: Option<&str>,
) -> Result<String, ControllerError> {
    let policy_payload: Vec<SessionRegistrationPolicyPayload> =
        canonicalize_session_policies(policies)?
            .iter()
            .map(|policy| SessionRegistrationPolicyPayload {
                target: policy.contract_address_hex.clone(),
                method: policy.entrypoint.clone(),
            })
            .collect();

    let policies_json = serde_json::to_string(&policy_payload).map_err(|e| {
        ControllerError::InvalidInput(format!("Failed to serialize session policies: {}", e))
    })?;

    let keychain_base = keychain_url.trim_end_matches('/');
    let mut registration_url = Url::parse(&format!("{}/session", keychain_base))
        .map_err(|e| ControllerError::InvalidInput(format!("Invalid keychain_url: {}", e)))?;

    let mut query = registration_url.query_pairs_mut();
    query
        .append_pair("public_key", public_key)
        .append_pair("policies", &policies_json)
        .append_pair("rpc_url", rpc_url);

    if let Some(preset) = preset.filter(|p| !p.is_empty()) {
        query.append_pair("preset", preset);
    }
    drop(query);

    Ok(registration_url.to_string())
}

fn shortener_endpoint(cartridge_api_url: &str) -> Result<String, ControllerError> {
    let api_base = cartridge_api_url
        .trim_end_matches("/query")
        .trim_end_matches('/');

    let endpoint = format!("{}/s", api_base);
    Url::parse(&endpoint)
        .map_err(|e| ControllerError::InvalidInput(format!("Invalid cartridge_api_url: {}", e)))?;

    Ok(endpoint)
}

fn validate_shortened_session_url(
    short_url: &str,
    expected_host: &str,
) -> Result<(), ControllerError> {
    let parsed = Url::parse(short_url)
        .map_err(|e| ControllerError::NetworkError(format!("Invalid short URL: {}", e)))?;

    let is_expected_host = parsed
        .host_str()
        .map(|host| host.eq_ignore_ascii_case(expected_host))
        .unwrap_or(false);
    if parsed.scheme() != "https" || !is_expected_host {
        return Err(ControllerError::NetworkError(
            "Short URL has unexpected host or scheme".to_string(),
        ));
    }

    let code = parsed.path().strip_prefix("/s/").unwrap_or_default();
    if code.len() != 10 || !code.chars().all(|c| c.is_ascii_alphanumeric()) {
        return Err(ControllerError::NetworkError(
            "Short URL has invalid code format".to_string(),
        ));
    }

    Ok(())
}

fn parse_shorten_response(
    status: StatusCode,
    body: &[u8],
    expected_host: &str,
) -> Result<String, ControllerError> {
    if !status.is_success() {
        return Err(ControllerError::NetworkError(format!(
            "URL shortener returned status {}",
            status
        )));
    }

    let response: ShortenResponse = serde_json::from_slice(body).map_err(|e| {
        ControllerError::NetworkError(format!("Failed to parse shortener response: {}", e))
    })?;

    validate_shortened_session_url(&response.url, expected_host)?;
    Ok(response.url)
}

fn create_session_registration_url_inner(
    private_key: String,
    policies: SessionPolicies,
    rpc_url: String,
    keychain_url: String,
    cartridge_api_url: String,
    preset: Option<String>,
) -> Result<String, ControllerError> {
    let private_key_felt =
        Felt::from_hex(&private_key).map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
    let public_key = starknet_crypto::get_public_key(&private_key_felt);
    let public_key_hex = format!("{:#x}", public_key);

    let long_url = build_session_registration_long_url(
        &public_key_hex,
        &policies,
        &rpc_url,
        &keychain_url,
        preset.as_deref(),
    )?;
    let endpoint = shortener_endpoint(&cartridge_api_url)?;
    let endpoint_url = Url::parse(&endpoint)
        .map_err(|e| ControllerError::InvalidInput(format!("Invalid shortener endpoint: {}", e)))?;
    let expected_host = endpoint_url
        .host_str()
        .ok_or_else(|| {
            ControllerError::InvalidInput("Shortener endpoint must have a host".to_string())
        })?
        .to_string();

    RUNTIME.block_on(async move {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(5))
            .build()
            .map_err(|e| ControllerError::NetworkError(format!("Failed to build client: {}", e)))?;

        let response = client
            .post(endpoint)
            .json(&ShortenRequest { url: &long_url })
            .send()
            .await
            .map_err(|e| {
                ControllerError::NetworkError(format!("Failed to shorten session URL: {}", e))
            })?;

        let status = response.status();
        let bytes = response.bytes().await.map_err(|e| {
            ControllerError::NetworkError(format!("Failed to read shortener response: {}", e))
        })?;

        parse_shorten_response(status, &bytes, &expected_host)
    })
}

pub fn create_session_registration_url(
    private_key: String,
    policies: SessionPolicies,
    rpc_url: String,
    preset: Option<String>,
) -> Result<String, ControllerError> {
    create_session_registration_url_inner(
        private_key,
        policies,
        rpc_url,
        KEYCHAIN_BASE_URL.to_string(),
        CARTRIDGE_API_BASE_URL.to_string(),
        preset,
    )
}

pub fn create_session_registration_url_with_urls(
    private_key: String,
    policies: SessionPolicies,
    rpc_url: String,
    keychain_url: String,
    cartridge_api_url: String,
    preset: Option<String>,
) -> Result<String, ControllerError> {
    create_session_registration_url_inner(
        private_key,
        policies,
        rpc_url,
        keychain_url,
        cartridge_api_url,
        preset,
    )
}

// Session Account implementation
pub(crate) struct SessionAccountInner {
    pub session_account: SdkSessionAccount,
    pub last_error: Option<String>,
    pub owner_guid: Felt,
    pub expires_at: u64,
    // Additional metadata from GraphQL response (only populated when using create_from_subscribe)
    pub session_id: Option<String>,
    pub username: Option<String>, // controller.accountID
    pub app_id: Option<String>,
    pub is_revoked: bool,
}

pub struct SessionAccount {
    pub(crate) inner: Arc<Mutex<SessionAccountInner>>,
}

impl SessionAccount {
    pub fn new(
        rpc_url: String,
        private_key: String,
        address: ControllerFieldElement,
        owner_guid: ControllerFieldElement,
        chain_id: ControllerFieldElement,
        policies: SessionPolicies,
        session_expiration: u64,
    ) -> Result<Self, ControllerError> {
        let rpc_url_parsed = Url::parse(&rpc_url)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let provider = CartridgeJsonRpcProvider::new(rpc_url_parsed);

        let address_felt = Felt::from_hex(&address.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let chain_id_felt = Felt::from_hex(&chain_id.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let owner_guid_felt = Felt::from_hex(&owner_guid.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let private_key_felt = Felt::from_hex(&private_key)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let signing_key = SigningKey::from_secret_scalar(private_key_felt);
        let signer = account_sdk::signers::Signer::Starknet(signing_key);

        let policy_vec: Vec<account_sdk::account::session::policy::Policy> =
            (&policies).try_into()?;

        let session = account_sdk::account::session::hash::Session::new(
            policy_vec,
            session_expiration,
            &signer.clone().into(),
            Felt::ZERO,
        )
        .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let session_account = SdkSessionAccount::new_as_registered(
            provider,
            signer,
            address_felt,
            chain_id_felt,
            owner_guid_felt,
            session,
        );

        Ok(Self {
            inner: Arc::new(Mutex::new(SessionAccountInner {
                session_account,
                last_error: None,
                owner_guid: owner_guid_felt,
                expires_at: session_expiration,
                session_id: None,
                username: None,
                app_id: None,
                is_revoked: false,
            })),
        })
    }

    pub fn execute(&self, calls: Vec<Call>) -> Result<ControllerFieldElement, ControllerError> {
        let calls_vec: Result<Vec<starknet::core::types::Call>, _> =
            calls.iter().map(|c| c.try_into()).collect();
        let calls_vec = calls_vec?;

        let mut inner = self.inner.lock().unwrap();

        // Use global multi-threaded runtime
        let result = RUNTIME.block_on(inner.session_account.execute_v3(calls_vec).send());

        match result {
            Ok(res) => Ok(ControllerFieldElement(format!(
                "{:#x}",
                res.transaction_hash
            ))),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::ExecutionError(err_msg))
            }
        }
    }

    pub fn execute_from_outside(
        &self,
        calls: Vec<Call>,
    ) -> Result<ControllerFieldElement, ControllerError> {
        use account_sdk::abigen::controller::OutsideExecutionV3;
        use account_sdk::account::outside_execution::{OutsideExecution, OutsideExecutionCaller};

        let calls_vec: Result<Vec<starknet::core::types::Call>, _> =
            calls.iter().map(|c| c.try_into()).collect();
        let calls_vec = calls_vec?;

        let caller = OutsideExecutionCaller::Any;
        let now = Utc::now().timestamp() as u64;

        // Convert starknet::core::types::Call to account_sdk::abigen::controller::Call
        let sdk_calls: Vec<account_sdk::abigen::controller::Call> = calls_vec
            .iter()
            .map(|c| account_sdk::abigen::controller::Call {
                to: c.to.into(),
                selector: c.selector,
                calldata: c.calldata.clone(),
            })
            .collect();

        let outside_execution = OutsideExecutionV3 {
            caller: caller.into(),
            execute_after: 0_u64,
            execute_before: now + 600,
            calls: sdk_calls,
            nonce: (SigningKey::from_random().secret_scalar(), 1),
        };

        let mut inner = self.inner.lock().unwrap();

        // Use global multi-threaded runtime
        let result = RUNTIME.block_on(async {
            let signed = inner
                .session_account
                .sign_outside_execution(OutsideExecution::V3(outside_execution.clone()))
                .await
                .map_err(|e| ControllerError::ExecutionError(e.to_string()))?;

            let address = inner.session_account.address();
            let provider = inner.session_account.provider();

            let res = provider
                .add_execute_outside_transaction(
                    OutsideExecution::V3(outside_execution),
                    address,
                    signed.signature,
                    None,
                )
                .await
                .map_err(|e| ControllerError::ExecutionError(e.to_string()))?;

            Ok::<String, ControllerError>(res.transaction_hash.to_hex_string())
        });

        match result {
            Ok(tx_hash) => Ok(ControllerFieldElement(tx_hash)),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(e)
            }
        }
    }

    pub fn create_from_subscribe(
        private_key: String,
        policies: SessionPolicies,
        rpc_url: String,
        cartridge_api_url: String,
    ) -> Result<Self, ControllerError> {
        // Parse private key and create signer
        let private_key_felt = Felt::from_hex(&private_key)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let signing_key = SigningKey::from_secret_scalar(private_key_felt);
        let signer = account_sdk::signers::Signer::Starknet(signing_key);

        // Get session key GUID
        let session_key_guid: Felt = signer.clone().into();

        // Call the GraphQL API to create the session
        // Use global multi-threaded runtime to avoid blocking the caller's thread
        let response_data = RUNTIME
            .block_on(account_sdk::session::subscribe_create_session(
                session_key_guid,
                cartridge_api_url,
            ))
            .map_err(|e| ControllerError::SignupError(format!("Failed to subscribe: {}", e)))?;

        // Extract data from response
        let data = response_data.subscribe_create_session.ok_or_else(|| {
            ControllerError::SignupError("No data inside the subscribe create session".to_string())
        })?;

        // Validate authorization
        if data.authorization.is_empty() {
            return Err(ControllerError::SignupError(
                "No authorization in response".to_string(),
            ));
        }

        if Felt::from_hex(&data.authorization[0])
            .map_err(|e| ControllerError::SignupError(e.to_string()))?
            != short_string!("authorization-by-registered")
        {
            return Err(ControllerError::SignupError(
                "Invalid authorization".to_string(),
            ));
        }

        if data.authorization.len() < 2 {
            return Err(ControllerError::SignupError(
                "Missing owner_guid in authorization".to_string(),
            ));
        }

        // Extract session parameters
        let address = ControllerFieldElement(data.controller.address.clone());
        let owner_guid = ControllerFieldElement(data.authorization[1].clone());
        let chain_id_felt = cairo_short_string_to_felt(&data.chain_id).map_err(|e| {
            ControllerError::InitializationError(format!("Failed to parse chainId: {}", e))
        })?;
        let chain_id = ControllerFieldElement(format!("{:#x}", chain_id_felt));

        // Extract additional metadata
        let session_id = Some(data.id.clone());
        let username = data.controller.account_id.clone();
        let app_id = Some(data.app_id.clone());
        let is_revoked = data.is_revoked;

        // Create the session account using the regular constructor
        let session_account = Self::new(
            rpc_url,
            private_key,
            address,
            owner_guid,
            chain_id,
            policies,
            data.expires_at,
        )?;

        // Update the inner struct with additional metadata
        {
            let mut inner = session_account.inner.lock().unwrap();
            inner.session_id = session_id;
            inner.username = Some(username);
            inner.app_id = app_id;
            inner.is_revoked = is_revoked;
        }

        Ok(session_account)
    }

    /// Get the session account address
    pub fn address(&self) -> String {
        let inner = self.inner.lock().unwrap();
        format!("{:#x}", inner.session_account.address())
    }

    /// Get the chain ID
    pub fn chain_id(&self) -> String {
        let inner = self.inner.lock().unwrap();
        format!("{:#x}", inner.session_account.chain_id())
    }

    /// Get the owner GUID
    pub fn owner_guid(&self) -> String {
        let inner = self.inner.lock().unwrap();
        format!("{:#x}", inner.owner_guid)
    }

    /// Get the session expiration timestamp (Unix timestamp in seconds)
    pub fn expires_at(&self) -> u64 {
        let inner = self.inner.lock().unwrap();
        inner.expires_at
    }

    /// Check if the session is expired
    pub fn is_expired(&self) -> bool {
        let inner = self.inner.lock().unwrap();
        let now = Utc::now().timestamp() as u64;
        now >= inner.expires_at
    }

    /// Get the session ID
    pub fn session_id(&self) -> Option<String> {
        let inner = self.inner.lock().unwrap();
        inner.session_id.clone()
    }

    /// Get the username (controller.accountID)
    pub fn username(&self) -> Option<String> {
        let inner = self.inner.lock().unwrap();
        inner.username.clone()
    }

    /// Get the app ID
    pub fn app_id(&self) -> Option<String> {
        let inner = self.inner.lock().unwrap();
        inner.app_id.clone()
    }

    /// Check if the session is revoked
    pub fn is_revoked(&self) -> bool {
        let inner = self.inner.lock().unwrap();
        inner.is_revoked
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::HashMap;

    #[test]
    fn builds_registration_long_url_with_expected_query() {
        let policies = SessionPolicies {
            policies: vec![crate::types::SessionPolicy {
                contract_address: ControllerFieldElement("0xabc".to_string()),
                entrypoint: "transfer".to_string(),
            }],
            max_fee: ControllerFieldElement("0x1".to_string()),
        };

        let url = build_session_registration_long_url(
            "0x123",
            &policies,
            "https://api.cartridge.gg/x/starknet/sepolia",
            "https://x.cartridge.gg",
            None,
        )
        .expect("build URL");

        let parsed = Url::parse(&url).expect("parse url");
        assert_eq!(parsed.scheme(), "https");
        assert_eq!(parsed.host_str(), Some("x.cartridge.gg"));
        assert_eq!(parsed.path(), "/session");

        let params: HashMap<String, String> = parsed
            .query_pairs()
            .map(|(k, v)| (k.into_owned(), v.into_owned()))
            .collect();

        assert_eq!(params.get("public_key"), Some(&"0x123".to_string()));
        assert_eq!(
            params.get("rpc_url"),
            Some(&"https://api.cartridge.gg/x/starknet/sepolia".to_string())
        );
        assert_eq!(
            params.get("policies"),
            Some(
                &r#"[{"target":"0x0000000000000000000000000000000000000000000000000000000000000abc","method":"transfer"}]"#
                    .to_string()
            )
        );
        assert_eq!(params.get("preset"), None);
    }

    #[test]
    fn includes_preset_when_provided() {
        let policies = SessionPolicies {
            policies: vec![crate::types::SessionPolicy {
                contract_address: ControllerFieldElement("0xabc".to_string()),
                entrypoint: "transfer".to_string(),
            }],
            max_fee: ControllerFieldElement("0x1".to_string()),
        };

        let url = build_session_registration_long_url(
            "0x123",
            &policies,
            "https://api.cartridge.gg/x/starknet/sepolia",
            "https://x.cartridge.gg",
            Some("quick"),
        )
        .expect("build URL");

        let parsed = Url::parse(&url).expect("parse url");
        let params: HashMap<String, String> = parsed
            .query_pairs()
            .map(|(k, v)| (k.into_owned(), v.into_owned()))
            .collect();

        assert_eq!(params.get("preset"), Some(&"quick".to_string()));
    }

    #[test]
    fn builds_shortener_endpoint_from_query_url() {
        let endpoint = shortener_endpoint("https://api.cartridge.gg/query").expect("endpoint");
        assert_eq!(endpoint, "https://api.cartridge.gg/s");
    }

    #[test]
    fn validates_shortened_url_shape() {
        assert!(validate_shortened_session_url(
            "https://api.cartridge.gg/s/AbC123dEf9",
            "api.cartridge.gg"
        )
        .is_ok());
        assert!(validate_shortened_session_url(
            "https://api.cartridge.gg/s/short",
            "api.cartridge.gg"
        )
        .is_err());
        assert!(validate_shortened_session_url(
            "https://evil.com/s/AbC123dEf9",
            "api.cartridge.gg"
        )
        .is_err());
    }

    #[test]
    fn parses_shortener_response() {
        let body = br#"{"url":"https://api.cartridge.gg/s/a1B2c3D4e5"}"#;
        let parsed = parse_shorten_response(StatusCode::OK, body, "api.cartridge.gg")
            .expect("parse response");
        assert_eq!(parsed, "https://api.cartridge.gg/s/a1B2c3D4e5");
    }

    #[test]
    fn canonicalizes_policy_order_in_registration_url() {
        let policies = SessionPolicies {
            policies: vec![
                crate::types::SessionPolicy {
                    contract_address: ControllerFieldElement("0x10".to_string()),
                    entrypoint: "zeta".to_string(),
                },
                crate::types::SessionPolicy {
                    contract_address: ControllerFieldElement("0x2".to_string()),
                    entrypoint: "beta".to_string(),
                },
                crate::types::SessionPolicy {
                    contract_address: ControllerFieldElement("0x2".to_string()),
                    entrypoint: "alpha".to_string(),
                },
            ],
            max_fee: ControllerFieldElement("0x1".to_string()),
        };

        let url = build_session_registration_long_url(
            "0x123",
            &policies,
            "https://api.cartridge.gg/x/starknet/sepolia",
            "https://x.cartridge.gg",
            None,
        )
        .expect("build URL");

        let parsed = Url::parse(&url).expect("parse url");
        let params: HashMap<String, String> = parsed
            .query_pairs()
            .map(|(k, v)| (k.into_owned(), v.into_owned()))
            .collect();

        assert_eq!(
            params.get("policies"),
            Some(
                &r#"[{"target":"0x0000000000000000000000000000000000000000000000000000000000000002","method":"alpha"},{"target":"0x0000000000000000000000000000000000000000000000000000000000000002","method":"beta"},{"target":"0x0000000000000000000000000000000000000000000000000000000000000010","method":"zeta"}]"#
                    .to_string()
            )
        );
    }
}
