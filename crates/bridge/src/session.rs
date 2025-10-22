use account_sdk::account::outside_execution::OutsideExecutionAccount;
use account_sdk::account::session::account::SessionAccount as SdkSessionAccount;
use account_sdk::provider::{CartridgeJsonRpcProvider, CartridgeProvider};
use starknet::accounts::{Account, ConnectedAccount};
use starknet::core::types::Felt;
use starknet::core::utils::cairo_short_string_to_felt;
use starknet::macros::short_string;
use starknet_signers::SigningKey;
use std::sync::{Arc, Mutex};
use url::Url;
use chrono::Utc;

use crate::error::ControllerError;
use crate::types::{Call, FieldElement, SessionPolicies};

// Session Account implementation
pub(crate) struct SessionAccountInner {
    pub session_account: SdkSessionAccount,
    pub last_error: Option<String>,
}

#[derive(uniffi::Object)]
pub struct SessionAccount {
    pub(crate) inner: Arc<Mutex<SessionAccountInner>>,
}

#[uniffi::export]
impl SessionAccount {
    #[uniffi::constructor]
    pub fn new(
        rpc_url: String,
        private_key: String,
        address: FieldElement,
        owner_guid: FieldElement,
        chain_id: FieldElement,
        policies: SessionPolicies,
        session_expiration: u64,
    ) -> Result<Arc<Self>, ControllerError> {
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

        let policy_vec: Vec<account_sdk::account::session::policy::Policy> = (&policies).try_into()?;
        
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

        Ok(Arc::new(Self {
            inner: Arc::new(Mutex::new(SessionAccountInner {
                session_account,
                last_error: None,
            })),
        }))
    }

    pub fn execute(&self, calls: Vec<Call>) -> Result<FieldElement, ControllerError> {
        let calls_vec: Result<Vec<starknet::core::types::Call>, _> =
            calls.iter().map(|c| c.try_into()).collect();
        let calls_vec = calls_vec?;

        let mut inner = self.inner.lock().unwrap();
        
        let result = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::ExecutionError(e.to_string()))?
            .block_on(inner.session_account.execute_v3(calls_vec).send());

        match result {
            Ok(res) => Ok(FieldElement(format!("{:#x}", res.transaction_hash))),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::ExecutionError(err_msg))
            }
        }
    }

    pub fn execute_from_outside(&self, calls: Vec<Call>) -> Result<FieldElement, ControllerError> {
        use account_sdk::account::outside_execution::{
            OutsideExecution, OutsideExecutionCaller,
        };
        use account_sdk::abigen::controller::OutsideExecutionV3;

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

        let result = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::ExecutionError(e.to_string()))?
            .block_on(async {
                let signed = inner.session_account
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
            Ok(tx_hash) => Ok(FieldElement(tx_hash)),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(e)
            }
        }
    }

    #[uniffi::constructor(name = "create_from_subscribe")]
    pub fn create_from_subscribe(
        private_key: String,
        policies: SessionPolicies,
        rpc_url: String,
        cartridge_api_url: String,
    ) -> Result<Arc<Self>, ControllerError> {
        // Parse private key and create signer
        let private_key_felt = Felt::from_hex(&private_key)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let signing_key = SigningKey::from_secret_scalar(private_key_felt);
        let signer = account_sdk::signers::Signer::Starknet(signing_key);
        
        // Get session key GUID
        let session_key_guid: Felt = signer.clone().into();

        // Call the GraphQL API to create the session
        let response_data = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?
            .block_on(account_sdk::session::subscribe_create_session(
                session_key_guid,
                cartridge_api_url,
            ))
            .map_err(|e| ControllerError::SignupError(format!("Failed to subscribe: {}", e)))?;

        // Extract data from response
        let data = response_data
            .subscribe_create_session
            .ok_or_else(|| ControllerError::SignupError(
                "No data inside the subscribe create session".to_string(),
            ))?;

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
        let address = FieldElement(data.controller.address.clone());
        let owner_guid = FieldElement(data.authorization[1].clone());
        let chain_id_felt = cairo_short_string_to_felt(&data.chain_id)
            .map_err(|e| ControllerError::InitializationError(format!("Failed to parse chainId: {}", e)))?;
        let chain_id = FieldElement(format!("{:#x}", chain_id_felt));

        // Create the session account using the regular constructor
        Self::new(
            rpc_url,
            private_key,
            address,
            owner_guid,
            chain_id,
            policies,
            data.expires_at,
        )
    }
}

