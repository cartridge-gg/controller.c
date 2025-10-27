use account_sdk::constants::STRK_CONTRACT_ADDRESS;
use account_sdk::controller::Controller as SdkController;
use starknet::accounts::Account;
use starknet::core::types::Felt;
use std::sync::{Arc, Mutex};
use url::Url;

use crate::error::ControllerError;
use crate::owner::Owner;
use crate::types::{Call, FieldElement, SignerType};
use std::ops::Deref;

// Controller implementation
pub(crate) struct ControllerInner {
    pub controller: SdkController,
    pub last_error: Option<String>,
}

pub struct Controller {
    pub(crate) inner: Arc<Mutex<ControllerInner>>,
}

impl Controller {
    pub fn new(
        app_id: String,
        username: String,
        class_hash: FieldElement,
        rpc_url: String,
        owner: Arc<Owner>,
        address: FieldElement,
        chain_id: FieldElement,
    ) -> Result<Self, ControllerError> {
        let class_hash_felt = Felt::from_hex(&class_hash.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let rpc_url_parsed = Url::parse(&rpc_url)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let address_felt = Felt::from_hex(&address.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let chain_id_felt = Felt::from_hex(&chain_id.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let controller = SdkController::new(
            app_id,
            username,
            class_hash_felt,
            rpc_url_parsed,
            owner.deref().inner.clone(),
            address_felt,
            chain_id_felt,
        );

        Ok(Self {
            inner: Arc::new(Mutex::new(ControllerInner {
                controller,
                last_error: None,
            })),
        })
    }

    pub fn new_headless(
        app_id: String,
        username: String,
        class_hash: FieldElement,
        rpc_url: String,
        owner: Arc<Owner>,
        chain_id: FieldElement,
    ) -> Result<Self, ControllerError> {
        let class_hash_felt = Felt::from_hex(&class_hash.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let rpc_url_parsed = Url::parse(&rpc_url)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;
        
        let chain_id_felt = Felt::from_hex(&chain_id.0)
            .map_err(|e| ControllerError::InitializationError(e.to_string()))?;

        let controller = SdkController::new_headless(
            app_id,
            username,
            class_hash_felt,
            rpc_url_parsed,
            owner.deref().inner.clone(),
            chain_id_felt,
        );

        Ok(Self {
            inner: Arc::new(Mutex::new(ControllerInner {
                controller,
                last_error: None,
            })),
        })
    }

    pub fn from_storage(app_id: String) -> Result<Self, ControllerError> {
        match SdkController::from_storage(app_id.clone()) {
            Ok(Some(controller)) => Ok(Self {
                inner: Arc::new(Mutex::new(ControllerInner {
                    controller,
                    last_error: None,
                })),
            }),
            Ok(None) => Err(ControllerError::StorageError(format!("No stored controller found for app_id: {}", app_id))),
            Err(e) => Err(ControllerError::StorageError(e.to_string())),
        }
    }

    pub fn signup(
        &self,
        signer_type: SignerType,
        session_expiration: Option<u64>,
        cartridge_api_url: Option<String>,
    ) -> Result<(), ControllerError> {
        let mut inner = self.inner.lock().unwrap();
        
        let result = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::SignupError(e.to_string()))?
            .block_on(inner.controller.signup(signer_type.into(), session_expiration, cartridge_api_url));

        match result {
            Ok(_) => Ok(()),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::SignupError(err_msg))
            }
        }
    }

    pub fn address(&self) -> Result<FieldElement, ControllerError> {
        let inner = self.inner.lock().unwrap();
        Ok(FieldElement(format!("{:#x}", inner.controller.address)))
    }

    pub fn username(&self) -> Result<String, ControllerError> {
        let inner = self.inner.lock().unwrap();
        Ok(inner.controller.username.clone())
    }

    pub fn app_id(&self) -> Result<String, ControllerError> {
        let inner = self.inner.lock().unwrap();
        Ok(inner.controller.app_id.clone())
    }

    pub fn chain_id(&self) -> Result<FieldElement, ControllerError> {
        let inner = self.inner.lock().unwrap();
        Ok(FieldElement(format!("{:#x}", inner.controller.chain_id)))
    }

    pub fn disconnect(&self) -> Result<(), ControllerError> {
        let mut inner = self.inner.lock().unwrap();
        inner.controller.disconnect().map_err(|e| {
            let err_msg = e.to_string();
            inner.last_error = Some(err_msg.clone());
            ControllerError::DisconnectError(err_msg)
        })?;
        Ok(())
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
            .block_on(inner.controller.execute_v3(calls_vec).send());

        match result {
            Ok(res) => Ok(FieldElement(format!("{:#x}", res.transaction_hash))),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::ExecutionError(err_msg))
            }
        }
    }

    pub fn switch_chain(&self, rpc_url: String) -> Result<(), ControllerError> {
        let mut inner = self.inner.lock().unwrap();
        
        let url = Url::parse(&rpc_url)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        let result = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::NetworkError(e.to_string()))?
            .block_on(inner.controller.switch_chain(url));

        match result {
            Ok(_) => Ok(()),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::NetworkError(err_msg))
            }
        }
    }

    pub fn delegate_account(&self) -> Result<FieldElement, ControllerError> {
        let inner = self.inner.lock().unwrap();
        
        let delegate = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::NetworkError(e.to_string()))?
            .block_on(inner.controller.delegate_account())
            .map_err(|e| ControllerError::NetworkError(e.to_string()))?;

        Ok(FieldElement(format!("{:#x}", delegate)))
    }

    pub fn transfer(
        &self,
        recipient: FieldElement,
        amount: FieldElement,
    ) -> Result<FieldElement, ControllerError> {
        let recipient_felt = Felt::from_hex(&recipient.0)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        let amount_felt = Felt::from_hex(&amount.0)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        let call = starknet::core::types::Call {
            to: STRK_CONTRACT_ADDRESS,
            selector: starknet::core::utils::get_selector_from_name("transfer").unwrap(),
            calldata: vec![recipient_felt, amount_felt, Felt::ZERO],
        };

        let mut inner = self.inner.lock().unwrap();
        let result = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .map_err(|e| ControllerError::ExecutionError(e.to_string()))?
            .block_on(inner.controller.execute_v3(vec![call]).send());

        match result {
            Ok(res) => Ok(FieldElement(format!("{:#x}", res.transaction_hash))),
            Err(e) => {
                let err_msg = e.to_string();
                inner.last_error = Some(err_msg.clone());
                Err(ControllerError::ExecutionError(err_msg))
            }
        }
    }

    pub fn error_message(&self) -> Result<String, ControllerError> {
        let inner = self.inner.lock().unwrap();
        Ok(inner.last_error.clone().unwrap_or_default())
    }

    pub fn clear_last_error(&self) {
        let mut inner = self.inner.lock().unwrap();
        inner.last_error = None;
    }
}

// Standalone utility function to check storage
pub fn controller_has_storage(app_id: String) -> Result<bool, ControllerError> {
    match SdkController::from_storage(app_id) {
        Ok(Some(_)) => Ok(true),
        Ok(None) => Ok(false),
        Err(e) => Err(ControllerError::StorageError(e.to_string())),
    }
}

