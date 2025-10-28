use crate::error::ControllerError;
use starknet::core::types::Felt;

// Custom type conversions
#[derive(Clone, Debug)]
pub struct FieldElement(pub String);

uniffi::custom_newtype!(FieldElement, String);

// Signer type enum
pub enum SignerType {
    Webauthn,
    Starknet,
}

impl From<SignerType> for account_sdk::signers::types::SignerType {
    fn from(val: SignerType) -> Self {
        match val {
            SignerType::Webauthn => account_sdk::signers::types::SignerType::Webauthn,
            SignerType::Starknet => account_sdk::signers::types::SignerType::Starknet,
        }
    }
}

// Call structure
pub struct Call {
    pub contract_address: FieldElement,
    pub entrypoint: String,
    pub calldata: Vec<FieldElement>,
}

impl TryFrom<&Call> for starknet::core::types::Call {
    type Error = ControllerError;

    fn try_from(call: &Call) -> Result<Self, Self::Error> {
        let contract_address = Felt::from_hex(&call.contract_address.0)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        let selector = starknet::core::utils::get_selector_from_name(&call.entrypoint)
            .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        let calldata: Result<Vec<Felt>, _> =
            call.calldata.iter().map(|s| Felt::from_hex(&s.0)).collect();
        let calldata = calldata.map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

        Ok(starknet::core::types::Call {
            to: contract_address,
            selector,
            calldata,
        })
    }
}

// Session policy
pub struct SessionPolicy {
    pub contract_address: FieldElement,
    pub entrypoint: String,
}

pub struct SessionPolicies {
    pub policies: Vec<SessionPolicy>,
    pub max_fee: FieldElement,
}

impl TryFrom<&SessionPolicies> for Vec<account_sdk::account::session::policy::Policy> {
    type Error = ControllerError;

    fn try_from(policies: &SessionPolicies) -> Result<Self, Self::Error> {
        let mut result = Vec::new();
        for policy in &policies.policies {
            let contract_address = Felt::from_hex(&policy.contract_address.0)
                .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

            let selector = starknet::core::utils::get_selector_from_name(&policy.entrypoint)
                .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
            let sdk_policy =
                account_sdk::account::session::policy::Policy::new_call(contract_address, selector);
            result.push(sdk_policy);
        }
        Ok(result)
    }
}
