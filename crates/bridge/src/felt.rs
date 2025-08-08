#[diplomat::bridge]
pub mod ffi {
    use diplomat_runtime::DiplomatStr;
    use starknet::core::types::Felt;

    use crate::ffi::{ControllerError, ErrorType};

    #[diplomat::opaque]
    pub struct DiplomatFelt(pub Felt);

    impl DiplomatFelt {
        pub fn new_from_hex(hex: &DiplomatStr) -> Result<Box<DiplomatFelt>, Box<ControllerError>> {
            let s = std::str::from_utf8(hex).map_err(|e| {
                Box::new(ControllerError {
                    error_type: ErrorType::InvalidInput,
                    message: format!("Invalid UTF-8 in felt hex: {e}"),
                })
            })?;
            let felt = Felt::from_hex(s).map_err(|e| {
                Box::new(ControllerError {
                    error_type: ErrorType::InvalidInput,
                    message: format!("Invalid felt hex: {e}"),
                })
            })?;
            Ok(Box::new(DiplomatFelt(felt)))
        }
        pub fn new_from_bytes(bytes: &[u8]) -> Result<Box<DiplomatFelt>, Box<ControllerError>> {
            Ok(Box::new(DiplomatFelt(Felt::from_bytes_be_slice(bytes))))
        }
    }

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
        pub fn push_calldata_bytes(&mut self, byte: &[u8]) {
            self.0.calldata.push(Felt::from_bytes_be_slice(byte));
        }
    }

    #[diplomat::opaque]
    pub struct DiplomatCallList {
        pub calls: Vec<DiplomatCall>,
    }

    impl DiplomatCallList {
        /// Create a new empty call list
        pub fn new() -> Box<DiplomatCallList> {
            Box::new(DiplomatCallList { calls: Vec::new() })
        }

        /// Add a call to the list
        pub fn add_call(&mut self, call: &DiplomatCall) {
            self.calls.push(DiplomatCall(call.0.clone()));
        }
    }
}
