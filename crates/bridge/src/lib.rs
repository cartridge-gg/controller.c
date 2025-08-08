pub mod constants;
pub mod felt;
pub mod signer;

#[diplomat::bridge]
pub mod ffi {
    use account_sdk::constants::STRK_CONTRACT_ADDRESS;
    use account_sdk::controller::Controller as SdkController;
    use diplomat_runtime::{DiplomatStr, DiplomatWrite};
    use lazy_static::lazy_static;
    use starknet::core::types::{Felt, FromStrError};
    use std::fmt::Write;
    use std::str::Utf8Error;
    use std::sync::{Arc, Mutex};
    use tokio::runtime::Runtime;
    use url::ParseError;
    use url::Url;

    lazy_static! {
        static ref RUNTIME: Arc<Runtime> =
            Arc::new(Runtime::new().expect("Failed to create Tokio runtime"));
    }

    /// Opaque handle to a Controller instance
    #[diplomat::opaque]
    pub struct Controller(pub Arc<Mutex<SdkController>>);

    /// Error types for controller operations
    #[diplomat::opaque]
    pub struct ControllerError {
        pub error_type: ErrorType,
        pub message: String,
    }

    pub enum ErrorType {
        InitError,
        RuntimeError,
        SessionError,
        InvalidInput,
        NotDeployed,
        InsufficientBalance,
    }

    impl ControllerError {
        fn new(error_type: ErrorType, message: String) -> Self {
            ControllerError {
                error_type,
                message,
            }
        }
    }

    // Re-export types from account_sdk
    pub use account_sdk::signers::{Owner, Signer};

    use crate::constants::ffi::SignerType;
    use crate::felt::ffi::DiplomatCallList;
    use crate::signer::ffi::DiplomatOwner;

    impl From<Utf8Error> for Box<ControllerError> {
        fn from(e: Utf8Error) -> Self {
            Box::new(ControllerError::new(ErrorType::InvalidInput, e.to_string()))
        }
    }

    impl From<FromStrError> for Box<ControllerError> {
        fn from(e: FromStrError) -> Self {
            Box::new(ControllerError::new(ErrorType::InvalidInput, e.to_string()))
        }
    }

    impl From<ParseError> for Box<ControllerError> {
        fn from(e: ParseError) -> Self {
            Box::new(ControllerError::new(ErrorType::InvalidInput, e.to_string()))
        }
    }

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
            let app_id_str = std::str::from_utf8(app_id)?.to_string();
            let username_str = std::str::from_utf8(username)?.to_string();
            let class_hash_str = std::str::from_utf8(class_hash)?.to_string();
            let class_hash_felt = Felt::from_hex(class_hash_str.as_str())?;
            let rpc_url_str = std::str::from_utf8(rpc_url)?.to_string();
            let rpc_url_parsed = Url::parse(rpc_url_str.as_str())?;
            let address_str = std::str::from_utf8(address)?.to_string();
            let address_felt = Felt::from_hex(address_str.as_str())?;
            let chain_id_str = std::str::from_utf8(chain_id)?.to_string();
            let chain_id_felt = Felt::from_hex(chain_id_str.as_str())?;

            let controller = SdkController::new(
                app_id_str,
                username_str,
                class_hash_felt,
                rpc_url_parsed,
                owner.0.clone(),
                address_felt,
                chain_id_felt,
            );

            Ok(Box::new(Controller(Arc::new(Mutex::new(controller)))))
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
            let app_id_str = std::str::from_utf8(app_id)?.to_string();
            let username_str = std::str::from_utf8(username)?.to_string();
            let class_hash_str = std::str::from_utf8(class_hash)?.to_string();
            let class_hash_felt = Felt::from_hex(class_hash_str.as_str())?;
            let rpc_url_str = std::str::from_utf8(rpc_url)?.to_string();
            let rpc_url_parsed = Url::parse(rpc_url_str.as_str())?;
            let chain_id_str = std::str::from_utf8(chain_id)?.to_string();
            let chain_id_felt = Felt::from_hex(chain_id_str.as_str())?;

            let controller = SdkController::new_headless(
                app_id_str,
                username_str,
                class_hash_felt,
                rpc_url_parsed,
                owner.0.clone(),
                chain_id_felt,
            );

            Ok(Box::new(Controller(Arc::new(Mutex::new(controller)))))
        }

        /// Creates a Controller from storage
        pub fn from_storage(
            app_id: &DiplomatStr,
        ) -> Result<Option<Box<Controller>>, Box<ControllerError>> {
            let app_id_str = std::str::from_utf8(app_id)
                .map_err(|e| {
                    Box::new(ControllerError::new(
                        ErrorType::InvalidInput,
                        format!("Invalid UTF-8 in app_id: {e}"),
                    ))
                })?
                .to_string();

            match SdkController::from_storage(app_id_str) {
                Ok(Some(controller)) => {
                    Ok(Some(Box::new(Controller(Arc::new(Mutex::new(controller))))))
                }
                Ok(None) => Err(Box::new(ControllerError::new(
                    ErrorType::InitError,
                    "No controller found in storage".to_string(),
                ))),
                Err(e) => Err(Box::new(ControllerError::new(
                    ErrorType::InitError,
                    e.to_string(),
                ))),
            }
        }

        pub fn signup(
            &self,
            signer_type: SignerType,
            session_expiration: Option<u64>,
            cartridge_api_url: Option<&DiplomatStr>,
        ) -> Result<(), Box<ControllerError>> {
            let mut inner = self.0.lock().unwrap();
            RUNTIME
                .block_on(inner.signup(
                    signer_type.into(),
                    session_expiration,
                    cartridge_api_url.map(|url| std::str::from_utf8(url).unwrap().to_string()),
                ))
                .map_err(|e| {
                    Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string()))
                })?;
            Ok(())
        }

        /// Gets the controller's address
        pub fn address(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{:#x}", inner.address).unwrap();
            Ok(())
        }

        /// Gets the controller's username
        pub fn username(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{}", inner.username).unwrap();
            Ok(())
        }

        /// Gets the controller's app ID
        pub fn app_id(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{}", inner.app_id).unwrap();
            Ok(())
        }

        /// Gets the controller's chain ID
        pub fn chain_id(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            write!(result, "{:#x}", inner.chain_id).unwrap();
            Ok(())
        }

        /// Disconnects the controller and clears storage
        pub fn disconnect(&self) -> Result<(), Box<ControllerError>> {
            let mut inner: std::sync::MutexGuard<'_, SdkController> = self.0.lock().unwrap();
            inner
                .disconnect()
                .map_err(|e| Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string())))
        }

        pub fn execute(
            &self,
            calls: &DiplomatCallList,
            write: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let calls_vec = calls
                .calls
                .iter()
                .map(|call| call.0.clone())
                .collect::<Vec<_>>();

            let mut inner = self.0.lock().unwrap();
            let ret = RUNTIME
                .block_on(inner.execute(calls_vec, None, None))
                .map_err(|e| {
                    Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string()))
                })?;
            write!(write, "{:#x}", ret.transaction_hash).unwrap();
            Ok(())
        }
        // /// Switches to a different chain
        // pub fn switch_chain(&self, rpc_url: &DiplomatStr) -> Result<(), Box<ControllerError>> {
        //     let mut inner = self.0.lock().unwrap();

        //     let rpc_url_str = std::str::from_utf8(rpc_url).map_err(|e| {
        //         Box::new(ControllerError::new(
        //             ErrorType::InvalidInput,
        //             format!("Invalid UTF-8 in rpc_url: {}", e),
        //         ))
        //     })?;

        //     let url = Url::parse(rpc_url_str).map_err(|e| {
        //         Box::new(ControllerError::new(
        //             ErrorType::InvalidInput,
        //             format!("Invalid RPC URL: {}", e),
        //         ))
        //     })?;

        //     inner
        //         .runtime
        //         .block_on(inner.controller.switch_chain(url))
        //         .map_err(|e| Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string())))
        // }

        /// Gets the delegate account address
        pub fn delegate_account(
            &self,
            result: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let inner = self.0.lock().unwrap();
            let delegate = RUNTIME.block_on(inner.delegate_account()).map_err(|e| {
                Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string()))
            })?;

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
            let recipient_str = std::str::from_utf8(recipient).map_err(|e| {
                Box::new(ControllerError::new(
                    ErrorType::InvalidInput,
                    format!("Invalid UTF-8 in recipient: {e}"),
                ))
            })?;

            let recipient_felt = Felt::from_hex(recipient_str).map_err(|e| {
                Box::new(ControllerError::new(
                    ErrorType::InvalidInput,
                    format!("Invalid recipient address: {e}"),
                ))
            })?;

            let amount_str = std::str::from_utf8(amount).map_err(|e| {
                Box::new(ControllerError::new(
                    ErrorType::InvalidInput,
                    format!("Invalid UTF-8 in amount: {e}"),
                ))
            })?;

            let amount_felt = Felt::from_hex(amount_str).map_err(|e| {
                Box::new(ControllerError::new(
                    ErrorType::InvalidInput,
                    format!("Invalid amount: {e}"),
                ))
            })?;

            let call = starknet::core::types::Call {
                to: STRK_CONTRACT_ADDRESS,
                selector: starknet::core::utils::get_selector_from_name("transfer").unwrap(),
                calldata: vec![recipient_felt, amount_felt, Felt::ZERO], // recipient, amount_low, amount_high
            };

            let tx_result = RUNTIME
                .block_on(self.0.lock().unwrap().execute(vec![call], None, None))
                .map_err(|e| {
                    Box::new(ControllerError::new(ErrorType::RuntimeError, e.to_string()))
                })?;

            write!(result, "{:#x}", tx_result.transaction_hash).unwrap();
            Ok(())
        }
    }

    impl ControllerError {
        /// Gets the error message
        pub fn message(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            write!(result, "{}", self.message).unwrap();
            Ok(())
        }

        /// Gets the error type
        pub fn error_type(&self) -> ErrorType {
            self.error_type
        }
    }
}
