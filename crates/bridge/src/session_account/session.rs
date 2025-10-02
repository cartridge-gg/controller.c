#[diplomat::bridge]
pub mod ffi {
    use crate::{
        error::ffi::ControllerError,
        session_account::policies::ffi::{ContractPolicy, SignMessagePolicy},
    };
    use account_sdk::account::session::policy::{CallPolicy, Policy, TypedDataPolicy};
    use diplomat_runtime::DiplomatWrite;
    use serde::{Deserialize, Serialize};
    use starknet::core::utils::cairo_short_string_to_felt;
    use starknet_crypto::Felt;
    use std::{collections::HashMap, fmt::Write};

    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct DiplomatSessionPolicies {
        #[serde(skip_serializing_if = "Option::is_none")]
        pub contracts: Option<HashMap<String, ContractPolicy>>,

        #[serde(skip_serializing_if = "Option::is_none")]
        pub messages: Option<Vec<SignMessagePolicy>>,
    }

    impl DiplomatSessionPolicies {
        pub fn new() -> Box<Self> {
            Box::new(DiplomatSessionPolicies {
                contracts: None,
                messages: None,
            })
        }

        pub fn add_contract_policy(&mut self, address: &str, policy: &ContractPolicy) {
            if self.contracts.is_none() {
                self.contracts = Some(HashMap::new());
            }
            if let Some(ref mut contracts) = self.contracts {
                contracts.insert(address.to_string(), policy.clone());
            }
        }

        pub fn add_message_policy(&mut self, policy: &SignMessagePolicy) {
            if self.messages.is_none() {
                self.messages = Some(Vec::new());
            }
            if let Some(ref mut messages) = self.messages {
                messages.push(policy.clone());
            }
        }

        pub fn to_url_string(&self, writeable: &mut DiplomatWrite) {
            let modified_policies = serde_json::json!({
                "verified": false,
                "contracts": self.contracts.as_ref().map(|contracts| {
                    contracts.iter().map(|(address, policy)| {
                        let modified_methods: Vec<serde_json::Value> = policy.methods.iter().map(|method| {
                            serde_json::json!({
                                "name": method.name,
                                "description": method.description,
                                "entrypoint": method.entrypoint,
                                "is_enabled": method.is_enabled,
                                "is_required": method.is_required,
                                "is_paymastered": method.is_paymastered,
                                "authorized": true
                            })
                        }).collect();

                        (address.clone(), serde_json::json!({
                            "name": policy.name,
                            "description": policy.description,
                            "methods": modified_methods
                        }))
                    }).collect::<HashMap<String, serde_json::Value>>()
                }),
                "messages": self.messages.as_ref().map(|messages| {
                    messages.iter().map(|message| {
                        serde_json::json!({
                            "scope_hash": message.scope_hash,
                            "name": message.name,
                            "description": message.description,
                            "is_required": message.is_required,
                            "authorized": true
                        })
                    }).collect::<Vec<serde_json::Value>>()
                })
            });
            let json_string = serde_json::to_string(&modified_policies).unwrap_or_default();
            let _ = write!(writeable, "{}", json_string);
        }
    }

    impl TryFrom<DiplomatSessionPolicies> for Vec<Policy> {
        type Error = Box<ControllerError>;
        fn try_from(value: DiplomatSessionPolicies) -> Result<Self, Self::Error> {
            let mut policies = Vec::new();
            if let Some(contracts) = value.contracts {
                for (contract_address, policy) in contracts {
                    for method in policy.methods {
                        let call_policy = CallPolicy {
                            authorized: Some(true),
                            contract_address: Felt::from_hex(&contract_address)
                                .map_err(|e| Box::new(ControllerError(e.to_string())))?,
                            selector: cairo_short_string_to_felt(&method.entrypoint)
                                .map_err(|e| Box::new(ControllerError(e.to_string())))?,
                        };
                        policies.push(Policy::Call(call_policy));
                    }
                }
            };
            if let Some(messages) = value.messages {
                for policy in messages {
                    let typed_data_policy = TypedDataPolicy {
                        authorized: policy.authorized,
                        scope_hash: policy.scope_hash,
                    };
                    policies.push(Policy::TypedData(typed_data_policy));
                }
            };
            Ok(policies)
        }
    }

    impl TryFrom<&DiplomatSessionPolicies> for Vec<Policy> {
        type Error = Box<ControllerError>;
        fn try_from(value: &DiplomatSessionPolicies) -> Result<Self, Self::Error> {
            value.clone().try_into()
        }
    }
}
