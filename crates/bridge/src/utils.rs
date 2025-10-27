use starknet::core::types::Felt;
use starknet_signers::SigningKey;

use crate::error::ControllerError;
use crate::types::FieldElement;

/// Utility functions
pub fn validate_felt(felt: String) -> Result<bool, ControllerError> {
    // Simple validation - check if it's a valid hex string
    if felt.starts_with("0x") || felt.starts_with("0X") {
        Ok(true)
    } else {
        Err(ControllerError::InvalidInput(format!(
            "Invalid FieldElement: {}",
            felt
        )))
    }
}

pub fn get_public_key(private_key: FieldElement) -> Result<FieldElement, ControllerError> {
    let felt = Felt::from_hex(&private_key.0)
        .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
    
    let public_key = starknet_crypto::get_public_key(&felt);
    Ok(FieldElement(format!("{:#x}", public_key)))
}

pub fn signer_to_guid(private_key: FieldElement) -> Result<FieldElement, ControllerError> {
    let felt = Felt::from_hex(&private_key.0)
        .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
    
    let signing_key = SigningKey::from_secret_scalar(felt);
    let signer = account_sdk::signers::Signer::Starknet(signing_key);
    let guid: Felt = signer.into();
    
    Ok(FieldElement(format!("{:#x}", guid)))
}
