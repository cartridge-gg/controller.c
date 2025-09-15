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
    use account_sdk::signers::Signer;
    use chrono::Utc;
    use diplomat_runtime::{DiplomatStr, DiplomatWrite};
    use starknet::accounts::{Account, ConnectedAccount};
    use starknet::core::types::Felt;
    use starknet::signers::SigningKey;
    use std::fmt::Write;
    use std::sync::{Arc, Mutex};
    use tokio::runtime::Runtime;
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
    use crate::session_account::session::ffi::DiplomatPolicies;

    impl SessionAccount {
        /// Creates a new Controller instance
        pub fn new_as_registered(
            rpc_url: &DiplomatStr,
            signer: &DiplomatFelt,
            address: &DiplomatFelt,
            owner_guid: &DiplomatFelt,
            chain_id: &DiplomatFelt,
            policies: &DiplomatPolicies,
            session_expiration: u64,
        ) -> Result<Box<SessionAccount>, Box<ControllerError>> {
            let rpc_url_str = std::str::from_utf8(rpc_url)
                .map_err(|e| crate::error::ffi::store_error!(e))?
                .to_string();
            let rpc_url_parsed =
                Url::parse(rpc_url_str.as_str()).map_err(|e| crate::error::ffi::store_error!(e))?;
            let provider = CartridgeJsonRpcProvider::new(rpc_url_parsed);

            let signer = Signer::Starknet(SigningKey::from_secret_scalar(signer.0));
            let address = address.0;
            let chain_id = chain_id.0;

            let session = account_sdk::account::session::hash::Session::new(
                policies.into(),
                session_expiration,
                &signer.clone().into(),
                Felt::ZERO,
            )
            .map_err(|e| crate::error::ffi::store_error!(e))?;

            Ok(Box::new(SessionAccount(Arc::new(Mutex::new(
                SessionAccountInner {
                    session_account: SdkSessionAccount::new_as_registered(
                        provider,
                        signer,
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
                            .map_err(|e| crate::error::ffi::store_error!(e))?;

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
                            .map_err(|e| crate::error::ffi::store_error!(e))?;
                        Ok::<ExecuteFromOutsideResponse, Box<ControllerError>>(res)
                    }
                })?;

            write!(txn_write, "{}", ret.transaction_hash.to_hex_string()).unwrap();

            Ok(())
        }
    }
}
