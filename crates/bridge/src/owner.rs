use starknet::core::types::Felt;
use starknet_signers::SigningKey;

use crate::error::ControllerError;

// Owner wrapper
pub struct Owner {
    pub(crate) inner: account_sdk::signers::Owner,
}

impl Owner {
    pub fn new(private_key: String) -> Result<Self, ControllerError> {
        let felt = Felt::from_hex(&private_key)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
        
        let signing_key = SigningKey::from_secret_scalar(felt);
        let signer = account_sdk::signers::Signer::Starknet(signing_key);
        let owner = account_sdk::signers::Owner::Signer(signer);

        Ok(Self { inner: owner })
    }
}
