pub mod policies;
pub mod session;

#[diplomat::bridge]
pub mod ffi {
    use account_sdk::abigen::controller::OutsideExecutionV3;
    use account_sdk::account::outside_execution::{
        OutsideExecution, OutsideExecutionAccount, OutsideExecutionCaller,
    };
    use account_sdk::account::session::account::SessionAccount as SdkSessionAccount;
    use account_sdk::provider::{
        CartridgeJsonRpcProvider, CartridgeProvider, ExecuteFromOutsideResponse,
    };
    use chrono::Utc;
    use diplomat_runtime::{DiplomatStr, DiplomatWrite};
    use starknet::accounts::{Account, ConnectedAccount};
    use starknet::core::types::Felt;
    use starknet::core::utils::cairo_short_string_to_felt;
    use starknet::macros::short_string;
    use starknet::signers::SigningKey;
    use std::fmt::Write;
    use std::sync::{Arc, Mutex};
    use url::Url;

    /// Session Account Wrapper
    #[diplomat::opaque]
    struct SessionAccountInner {
        session_account: SdkSessionAccount,
        last_error: DiplomatOption<String>,
    }

    /// Opaque handle to a Controller instance
    #[diplomat::opaque]
    pub struct SessionAccount(Arc<Mutex<SessionAccountInner>>);

    use crate::error::ffi::ControllerError;
    use crate::felt::ffi::{DiplomatCallList, DiplomatFelt};
    use crate::session_account::session::ffi::DiplomatSessionPolicies;
    use crate::signer::ffi::DiplomatSigner;
    use crate::utils::ffi::Utils;

    impl SessionAccount {
        pub fn create_from_subscribe_create_session(
            signer: &DiplomatSigner,
            policies: &DiplomatSessionPolicies,
            rpc_url: &DiplomatStr,
            cartridge_api_url: &str,
        ) -> Result<Box<SessionAccount>, Box<ControllerError>> {
            let session_key_guid: DiplomatFelt = signer.into();
            let response_data_out =
                Utils::subscribe_create_session(&session_key_guid, cartridge_api_url)?;

            let data = response_data_out
                .data
                .subscribe_create_session
                .ok_or(Box::new(ControllerError(
                    "No data inside the subscribe create session".to_string(),
                )))?;
            if Felt::from_hex(&data.authorization[0])
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                != short_string!("authorization-by-registered")
            {
                return Err(Box::new(ControllerError(
                    "Invalid authorization".to_string(),
                )));
            }

            Ok(Box::new(*SessionAccount::new_as_registered(
                rpc_url,
                signer,
                &data.controller.address.try_into()?,
                &(&data.authorization[1]).try_into()?,
                &cairo_short_string_to_felt(&data.chain_id)
                    .map_err(|e| {
                        Box::new(ControllerError(format!("Failed to parse chainId {}", e)))
                    })?
                    .into(),
                policies,
                data.expires_at,
            )?))
        }

        /// Creates a new Session Account instance
        pub fn new_as_registered(
            rpc_url: &DiplomatStr,
            signer: &DiplomatSigner,
            address: &DiplomatFelt,
            owner_guid: &DiplomatFelt,
            chain_id: &DiplomatFelt,
            policies: &DiplomatSessionPolicies,
            session_expiration: u64,
        ) -> Result<Box<SessionAccount>, Box<ControllerError>> {
            let rpc_url_str = std::str::from_utf8(rpc_url)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let rpc_url_parsed = Url::parse(rpc_url_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let provider = CartridgeJsonRpcProvider::new(rpc_url_parsed);

            let address = address.0;
            let chain_id = chain_id.0;

            let session = account_sdk::account::session::hash::Session::new(
                policies.try_into()?,
                session_expiration,
                &signer.into(),
                Felt::ZERO,
            )
            .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            Ok(Box::new(SessionAccount(Arc::new(Mutex::new(
                SessionAccountInner {
                    session_account: SdkSessionAccount::new_as_registered(
                        provider,
                        signer.into(),
                        address,
                        chain_id,
                        owner_guid.0,
                        session,
                    ),
                    last_error: None.into(),
                },
            )))))
        }

        pub fn execute(
            &self,
            calls: &DiplomatCallList,
            write: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let calls_vec = calls
                .0
                .iter()
                .map(|call| call.0.clone())
                .collect::<Vec<_>>();

            let mut inner = self.0.lock().unwrap();
            let ret = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(inner.session_account.execute_v3(calls_vec).send())
                .map_err(|e| {
                    inner.last_error = DiplomatOption::from(Some(e.to_string()));
                    Box::new(ControllerError(e.to_string()))
                })?;
            write!(write, "{:#x}", ret.transaction_hash).unwrap();
            Ok(())
        }

        pub fn execute_from_outside_v3(
            &self,
            calls: &DiplomatCallList,
            txn_write: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let caller = OutsideExecutionCaller::Any;

            let now = Utc::now().timestamp() as u64;
            let outside_execution = OutsideExecutionV3 {
                caller: caller.into(),
                execute_after: 0_u64,
                execute_before: now + 600,
                calls: calls.into(),
                nonce: (SigningKey::from_random().secret_scalar(), 1),
            };

            let session = self.0.lock().unwrap();

            let ret = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(async {
                    {
                        let signed = session
                            .session_account
                            .sign_outside_execution(OutsideExecution::V3(outside_execution.clone()))
                            .await
                            .map_err(|e| Box::new(ControllerError(e.to_string())))?;

                        let res = session
                            .session_account
                            .provider()
                            .add_execute_outside_transaction(
                                OutsideExecution::V3(outside_execution),
                                session.session_account.address(),
                                signed.signature,
                                None,
                            )
                            .await
                            .map_err(|e| Box::new(ControllerError(e.to_string())))?;
                        Ok::<ExecuteFromOutsideResponse, Box<ControllerError>>(res)
                    }
                })?;

            write!(txn_write, "{}", ret.transaction_hash.to_hex_string()).unwrap();

            Ok(())
        }
    }
}
