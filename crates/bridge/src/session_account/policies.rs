#[diplomat::bridge]
pub mod ffi {
    use std::collections::HashMap;

    use serde::{Deserialize, Serialize};
    use starknet_crypto::Felt;

    #[derive(Debug, Clone, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct Method {
        pub name: String,
        pub description: String,
        pub entrypoint: String,
        #[serde(default = "default_false")]
        pub is_enabled: bool,
        #[serde(default = "default_false")]
        pub is_required: bool,
        #[serde(default = "default_false")]
        pub is_paymastered: bool,
    }

    impl Method {
        pub fn new(
            name: &str,
            description: &str,
            entrypoint: &str,
            is_enabled: bool,
            is_required: bool,
            is_paymastered: bool,
        ) -> Box<Self> {
            Box::new(Self {
                name: name.to_string(),
                description: description.to_string(),
                entrypoint: entrypoint.to_string(),
                is_enabled,
                is_required,
                is_paymastered,
            })
        }
    }

    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct ContractPolicy {
        #[serde(skip_serializing_if = "Option::is_none")]
        pub name: Option<String>,

        #[serde(skip_serializing_if = "Option::is_none")]
        pub description: Option<String>,

        pub methods: Vec<Method>,
    }

    impl ContractPolicy {
        pub fn new(name: Option<&str>, description: Option<&str>) -> Box<Self> {
            Box::new(Self {
                name: name.map(|x| x.to_string()),
                description: description.map(|x| x.to_string()),
                methods: vec![],
            })
        }

        pub fn push_method(&mut self, method: &Method) -> () {
            self.methods.push(method.clone());
        }
    }

    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct TypedData {
        pub types: HashMap<String, Vec<StarknetType>>,
        pub primary_type: String,
        pub domain: StarknetDomain,
        pub message: serde_json::Value, // Using Value for dynamic object
    }

    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct StarknetType {
        pub name: String,
        pub r#type: String,
    }

    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct StarknetDomain {
        pub name: String,
        pub version: String,
        pub chain_id: String,
        pub revision: Option<String>,
    }

    // // Corresponds to: type SignMessagePolicy = TypedDataPolicy & { ... }
    #[derive(Clone, Debug, Serialize, Deserialize)]
    #[diplomat::opaque]
    pub struct SignMessagePolicy {
        pub scope_hash: Felt,
        #[serde(skip_serializing_if = "Option::is_none")]
        pub authorized: Option<bool>,

        #[serde(skip_serializing_if = "Option::is_none")]
        pub name: Option<String>,

        #[serde(skip_serializing_if = "Option::is_none")]
        pub description: Option<String>,

        #[serde(default = "default_false")]
        pub is_required: bool,
    }

    pub fn default_false() -> bool {
        false
    }
}
