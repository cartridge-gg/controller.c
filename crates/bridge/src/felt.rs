#[diplomat::bridge]
pub mod ffi {
    use account_sdk::abigen;
    use diplomat_runtime::DiplomatStr;
    use starknet::core::types::{Call, Felt};

    use crate::error::ffi::ControllerError;

    #[diplomat::opaque]
    pub struct DiplomatFelt(pub Felt);

    impl From<&DiplomatFelt> for Felt {
        fn from(value: &DiplomatFelt) -> Felt {
            value.0
        }
    }

    impl DiplomatFelt {
        pub fn new_from_hex(hex: &DiplomatStr) -> Result<Box<DiplomatFelt>, Box<ControllerError>> {
            let s = std::str::from_utf8(hex).map_err(|e| {
                Box::new(ControllerError(format!("Invalid UTF-8 in felt hex: {e}")))
            })?;
            let felt = Felt::from_hex(s)
                .map_err(|e| Box::new(ControllerError(format!("Invalid felt hex: {e}"))))?;
            Ok(Box::new(DiplomatFelt(felt)))
        }
        pub fn new_from_bytes_be(bytes: &[u8]) -> Result<Box<DiplomatFelt>, Box<ControllerError>> {
            Ok(Box::new(DiplomatFelt(Felt::from_bytes_be_slice(bytes))))
        }
    }

    #[derive(Clone)]
    #[diplomat::opaque]
    pub struct DiplomatCall(pub starknet::core::types::Call);

    impl DiplomatCall {
        pub fn new(to: &DiplomatStr, selector: &DiplomatStr) -> Box<DiplomatCall> {
            Box::new(DiplomatCall(starknet::core::types::Call {
                to: Felt::from_hex(std::str::from_utf8(to).unwrap()).unwrap(),
                selector: Felt::from_hex(std::str::from_utf8(selector).unwrap()).unwrap(),
                calldata: Vec::new(),
            }))
        }

        pub fn push_calldata_str(&mut self, felt: &DiplomatStr) {
            self.0
                .calldata
                .push(Felt::from_hex(std::str::from_utf8(felt).unwrap()).unwrap());
        }

        pub fn push_calldata_bytes_be(&mut self, byte: &[u8]) {
            self.0.calldata.push(Felt::from_bytes_be_slice(byte));
        }

        pub fn push_calldata(&mut self, felt: &DiplomatFelt) {
            self.0.calldata.push(felt.0);
        }
    }

    impl From<DiplomatCall> for Call {
        fn from(value: DiplomatCall) -> Call {
            value.0
        }
    }

    impl From<DiplomatCall> for abigen::controller::Call {
        fn from(value: DiplomatCall) -> abigen::controller::Call {
            value.0.into()
        }
    }

    #[diplomat::opaque]
    pub struct DiplomatCallList(pub Vec<DiplomatCall>);

    impl DiplomatCallList {
        /// Create a new empty call list
        pub fn new() -> Box<DiplomatCallList> {
            Box::new(DiplomatCallList(Vec::new()))
        }

        /// Add a call to the list
        pub fn add_call(&mut self, call: &DiplomatCall) {
            self.0.push(DiplomatCall(call.0.clone()));
        }
    }

    impl From<DiplomatCallList> for Vec<Call> {
        fn from(value: DiplomatCallList) -> Vec<Call> {
            value.0.iter().cloned().map(Into::into).collect::<Vec<_>>()
        }
    }

    impl From<DiplomatCallList> for Vec<abigen::controller::Call> {
        fn from(value: DiplomatCallList) -> Vec<abigen::controller::Call> {
            value.0.iter().cloned().map(Into::into).collect::<Vec<_>>()
        }
    }
    impl From<&DiplomatCallList> for Vec<abigen::controller::Call> {
        fn from(value: &DiplomatCallList) -> Vec<abigen::controller::Call> {
            value.0.iter().cloned().map(Into::into).collect::<Vec<_>>()
        }
    }
}
