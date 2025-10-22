use starknet::core::types::Felt;
use starknet_signers::SigningKey;
use std::sync::Arc;

use crate::error::ControllerError;

// Owner wrapper
#[derive(uniffi::Object)]
pub struct Owner {
    pub(crate) inner: account_sdk::signers::Owner,
}

#[uniffi::export]
impl Owner {
    #[uniffi::constructor]
    pub fn new(private_key: String) -> Result<Arc<Self>, ControllerError> {
        let felt = Felt::from_hex(&private_key)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
        
        let signing_key = SigningKey::from_secret_scalar(felt);
        let signer = account_sdk::signers::Signer::Starknet(signing_key);
        let owner = account_sdk::signers::Owner::Signer(signer);

        Ok(Arc::new(Self { inner: owner }))
    }
}
