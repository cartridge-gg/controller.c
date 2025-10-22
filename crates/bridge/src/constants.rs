use account_sdk::artifacts::CONTROLLERS as SDK_CONTROLLERS;
use crate::error::ControllerError;
use crate::types::FieldElement;

// Version enum for controller class hashes
#[derive(Clone, Copy)]
pub enum Version {
    V1_0_4,
    V1_0_5,
    V1_0_6,
    V1_0_7,
    V1_0_8,
    V1_0_9,
    Latest,
}

impl From<Version> for account_sdk::artifacts::Version {
    fn from(val: Version) -> Self {
        match val {
            Version::V1_0_4 => account_sdk::artifacts::Version::V1_0_4,
            Version::V1_0_5 => account_sdk::artifacts::Version::V1_0_5,
            Version::V1_0_6 => account_sdk::artifacts::Version::V1_0_6,
            Version::V1_0_7 => account_sdk::artifacts::Version::V1_0_7,
            Version::V1_0_8 => account_sdk::artifacts::Version::V1_0_8,
            Version::V1_0_9 => account_sdk::artifacts::Version::V1_0_9,
            Version::Latest => account_sdk::artifacts::Version::LATEST,
        }
    }
}

/// Get the class hash for a specific controller version
pub fn get_controller_class_hash(version: Version) -> Result<FieldElement, ControllerError> {
    let sdk_version: account_sdk::artifacts::Version = version.into();
    let class_hash = SDK_CONTROLLERS
        .get(&sdk_version)
        .ok_or_else(|| ControllerError::InvalidInput("Version not found".to_string()))?;
    
    Ok(FieldElement(format!("{:#x}", class_hash.hash)))
}

