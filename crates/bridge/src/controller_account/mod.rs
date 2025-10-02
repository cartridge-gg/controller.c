#[diplomat::bridge]
pub mod ffi {
    use account_sdk::constants::STRK_CONTRACT_ADDRESS;
    use account_sdk::controller::Controller as SdkController;
    use diplomat_runtime::{DiplomatStr, DiplomatWrite};
    use starknet::core::types::Felt;
    use std::fmt::Write;
    use std::sync::{Arc, Mutex};
    use url::Url;

    #[diplomat::opaque]
    struct ControllerInner {
        controller: SdkController,
        last_error: DiplomatOption<String>,
    }

    /// Opaque handle to a Controller instance
    #[diplomat::opaque]
    pub struct Controller(Arc<Mutex<ControllerInner>>);

    use crate::constants::ffi::SignerType;
    use crate::error::ffi::ControllerError;
    use crate::felt::ffi::DiplomatCallList;
    use crate::signer::ffi::DiplomatOwner;

    impl Controller {
        /// Creates a new Controller instance
        pub fn new(
            app_id: &DiplomatStr,
            username: &DiplomatStr,
            class_hash: &DiplomatStr,
            rpc_url: &DiplomatStr,
            owner: &DiplomatOwner,
            address: &DiplomatStr,
            chain_id: &DiplomatStr,
        ) -> Result<Box<Controller>, Box<ControllerError>> {
            let app_id_str = std::str::from_utf8(app_id)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let username_str = std::str::from_utf8(username)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let class_hash_str = std::str::from_utf8(class_hash)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let class_hash_felt = Felt::from_hex(class_hash_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let rpc_url_str = std::str::from_utf8(rpc_url)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let rpc_url_parsed = Url::parse(rpc_url_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let address_str = std::str::from_utf8(address)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let address_felt = Felt::from_hex(address_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let chain_id_str = std::str::from_utf8(chain_id)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let chain_id_felt = Felt::from_hex(chain_id_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let controller = SdkController::new(
                app_id_str,
                username_str,
                class_hash_felt,
                rpc_url_parsed,
                owner.0.clone(),
                address_felt,
                chain_id_felt,
            );

            Ok(Box::new(Controller(Arc::new(Mutex::new(
                ControllerInner {
                    controller,
                    last_error: DiplomatOption::from(None),
                },
            )))))
        }

        /// Creates a new Controller headless instance
        pub fn new_headless(
            app_id: &DiplomatStr,
            username: &DiplomatStr,
            class_hash: &DiplomatStr,
            rpc_url: &DiplomatStr,
            owner: &DiplomatOwner,
            chain_id: &DiplomatStr,
        ) -> Result<Box<Controller>, Box<ControllerError>> {
            let app_id_str = std::str::from_utf8(app_id)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let username_str = std::str::from_utf8(username)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let class_hash_str = std::str::from_utf8(class_hash)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let class_hash_felt = Felt::from_hex(class_hash_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let rpc_url_str = std::str::from_utf8(rpc_url)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let rpc_url_parsed = Url::parse(rpc_url_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;
            let chain_id_str = std::str::from_utf8(chain_id)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?
                .to_string();
            let chain_id_felt = Felt::from_hex(chain_id_str.as_str())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let controller = SdkController::new_headless(
                app_id_str,
                username_str,
                class_hash_felt,
                rpc_url_parsed,
                owner.0.clone(),
                chain_id_felt,
            );

            Ok(Box::new(Controller(Arc::new(Mutex::new(
                ControllerInner {
                    controller,
                    last_error: DiplomatOption::from(None),
                },
            )))))
        }

        /// Creates a Controller from storage
        pub fn from_storage(
            app_id: &DiplomatStr,
        ) -> Result<Option<Box<Controller>>, Box<ControllerError>> {
            let app_id_str = std::str::from_utf8(app_id)
                .map_err(|e| Box::new(ControllerError(format!("Invalid UTF-8 in app_id: {e}"))))?
                .to_string();

            match SdkController::from_storage(app_id_str) {
                Ok(Some(controller)) => Ok(Some(Box::new(Controller(Arc::new(Mutex::new(
                    ControllerInner {
                        controller,
                        last_error: DiplomatOption::from(None),
                    },
                )))))),
                Ok(None) => Err(Box::new(ControllerError(
                    ("No controller found in storage").to_string(),
                ))),
                Err(e) => Err(Box::new(ControllerError(e.to_string()))),
            }
        }

        pub fn signup(
            &self,
            signer_type: SignerType,
            session_expiration: Option<u64>,
            cartridge_api_url: Option<&DiplomatStr>,
        ) -> Result<(), Box<ControllerError>> {
            let mut inner = self.0.lock().unwrap();

            let result = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(inner.controller.signup(
                    signer_type.into(),
                    session_expiration,
                    cartridge_api_url.map(|url| std::str::from_utf8(url).unwrap().to_string()),
                ));

            result.map_err(|e| {
                let err_msg = e.to_string();
                inner.last_error = DiplomatOption::from(Some(err_msg.clone()));
                Box::new(ControllerError(err_msg))
            })?;

            Ok(())
        }

        /// Gets the controller's address
        pub fn address(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{:#x}", inner.controller.address).unwrap();
            Ok(())
        }

        /// Gets the controller's username
        pub fn username(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{}", inner.controller.username).unwrap();
            Ok(())
        }

        /// Gets the controller's app ID
        pub fn app_id(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{}", inner.controller.app_id).unwrap();
            Ok(())
        }

        /// Gets the controller's chain ID
        pub fn chain_id(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{:#x}", inner.controller.chain_id).unwrap();
            Ok(())
        }

        /// Disconnects the controller and clears storage
        pub fn disconnect(&self) -> Result<(), Box<ControllerError>> {
            let mut inner: std::sync::MutexGuard<'_, ControllerInner> = self.0.lock().unwrap();
            inner.controller.disconnect().map_err(|e| {
                inner.last_error = DiplomatOption::from(Some(e.to_string()));
                Box::new(ControllerError(e.to_string()))
            })?;
            Ok(())
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
                .block_on(inner.controller.execute(calls_vec, None, None))
                .map_err(|e| {
                    inner.last_error = DiplomatOption::from(Some(e.to_string()));
                    Box::new(ControllerError(e.to_string()))
                })?;
            write!(write, "{:#x}", ret.transaction_hash).unwrap();
            Ok(())
        }

        /// Switches to a different chain
        pub fn switch_chain(&self, rpc_url: &DiplomatStr) -> Result<(), Box<ControllerError>> {
            let mut inner = self.0.lock().unwrap();

            let rpc_url_str = std::str::from_utf8(rpc_url)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let url =
                Url::parse(rpc_url_str).map_err(|e| Box::new(ControllerError(e.to_string())))?;

            tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(inner.controller.switch_chain(url))
                .map_err(|e| {
                    inner.last_error = DiplomatOption::from(Some(e.to_string()));
                    Box::new(ControllerError(e.to_string()))
                })?;
            Ok(())
        }

        /// Gets the delegate account address
        pub fn delegate_account(
            &self,
            result: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            let delegate = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(inner.controller.delegate_account())
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            write!(result, "{delegate:#x}").unwrap();
            Ok(())
        }

        /// Execute a simple transfer
        pub fn transfer(
            &self,
            recipient: &DiplomatStr,
            amount: &DiplomatStr,
            result: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let recipient_str = std::str::from_utf8(recipient)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let recipient_felt = Felt::from_hex(recipient_str)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let amount_str = std::str::from_utf8(amount)
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let amount_felt =
                Felt::from_hex(amount_str).map_err(|e| Box::new(ControllerError(e.to_string())))?;

            let call = starknet::core::types::Call {
                to: STRK_CONTRACT_ADDRESS,
                selector: starknet::core::utils::get_selector_from_name("transfer").unwrap(),
                calldata: vec![recipient_felt, amount_felt, Felt::ZERO], // recipient, amount_low, amount_high
            };

            let mut inner = self.0.lock().unwrap();
            let tx_result = tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(inner.controller.execute(vec![call], None, None))
                .map_err(|e| Box::new(ControllerError(e.to_string())))?;

            write!(result, "{:#x}", tx_result.transaction_hash).unwrap();
            Ok(())
        }

        /// Gets the error message
        pub fn error_message(
            &self,
            result: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();

            if let Ok(error_str) = inner.last_error.as_ref() {
                write!(result, "{}", error_str).unwrap();
            }

            Ok(())
        }

        /// Clear the last error message
        pub fn clear_last_error(&self) {
            let mut inner = self.0.lock().unwrap();
            let error_msg = &mut inner.last_error;
            *error_msg = DiplomatOption::from(None);
        }
    }
}
