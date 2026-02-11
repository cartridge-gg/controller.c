use crate::error::ControllerError;
use starknet::core::types::Felt;

// Custom type conversions
#[derive(Clone, Debug)]
pub struct ControllerFieldElement(pub String);

uniffi::custom_newtype!(ControllerFieldElement, String);

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
    pub contract_address: ControllerFieldElement,
    pub entrypoint: String,
    pub calldata: Vec<ControllerFieldElement>,
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
    pub contract_address: ControllerFieldElement,
    pub entrypoint: String,
}

pub struct SessionPolicies {
    pub policies: Vec<SessionPolicy>,
    pub max_fee: ControllerFieldElement,
}

pub(crate) struct CanonicalSessionPolicy {
    pub(crate) contract_address: Felt,
    pub(crate) contract_address_hex: String,
    pub(crate) entrypoint: String,
}

pub(crate) fn canonicalize_session_policies(
    policies: &SessionPolicies,
) -> Result<Vec<CanonicalSessionPolicy>, ControllerError> {
    let mut entries = policies
        .policies
        .iter()
        .map(|policy| {
            let contract_address = Felt::from_hex(&policy.contract_address.0)
                .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;

            Ok(CanonicalSessionPolicy {
                contract_address,
                contract_address_hex: format!("0x{contract_address:064x}"),
                entrypoint: policy.entrypoint.clone(),
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    // Match controller canonical ordering: address, then entrypoint.
    entries.sort_by(|a, b| {
        a.contract_address_hex
            .cmp(&b.contract_address_hex)
            .then_with(|| {
                a.entrypoint
                    .to_ascii_lowercase()
                    .cmp(&b.entrypoint.to_ascii_lowercase())
            })
            .then_with(|| a.entrypoint.cmp(&b.entrypoint))
    });

    Ok(entries)
}

impl TryFrom<&SessionPolicies> for Vec<account_sdk::account::session::policy::Policy> {
    type Error = ControllerError;

    fn try_from(policies: &SessionPolicies) -> Result<Self, Self::Error> {
        let mut result = Vec::new();
        for policy in canonicalize_session_policies(policies)? {
            let selector = starknet::core::utils::get_selector_from_name(&policy.entrypoint)
                .map_err(|e| ControllerError::InvalidInput(e.to_string()))?;
            let sdk_policy = account_sdk::account::session::policy::Policy::new_call(
                policy.contract_address,
                selector,
            );
            result.push(sdk_policy);
        }
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn canonicalize_session_policies_sorts_by_padded_address_then_method() {
        let policies = SessionPolicies {
            policies: vec![
                SessionPolicy {
                    contract_address: ControllerFieldElement("0x10".to_string()),
                    entrypoint: "zeta".to_string(),
                },
                SessionPolicy {
                    contract_address: ControllerFieldElement("0x2".to_string()),
                    entrypoint: "alpha".to_string(),
                },
                SessionPolicy {
                    contract_address: ControllerFieldElement("0x2".to_string()),
                    entrypoint: "beta".to_string(),
                },
            ],
            max_fee: ControllerFieldElement("0x0".to_string()),
        };

        let canonical = canonicalize_session_policies(&policies).expect("canonicalize");
        let ordered = canonical
            .iter()
            .map(|p| (p.contract_address_hex.clone(), p.entrypoint.clone()))
            .collect::<Vec<_>>();

        assert_eq!(
            ordered,
            vec![
                (
                    "0x0000000000000000000000000000000000000000000000000000000000000002"
                        .to_string(),
                    "alpha".to_string()
                ),
                (
                    "0x0000000000000000000000000000000000000000000000000000000000000002"
                        .to_string(),
                    "beta".to_string()
                ),
                (
                    "0x0000000000000000000000000000000000000000000000000000000000000010"
                        .to_string(),
                    "zeta".to_string()
                ),
            ]
        );
    }
}
