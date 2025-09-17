#[diplomat::bridge]
pub mod ffi {
    use diplomat_runtime::DiplomatWrite;
    use starknet::core::types::FromStrError;
    use std::fmt::Write;
    use std::str::Utf8Error;
    use url::ParseError;

    /// Error types for controller operations
    #[diplomat::opaque]
    #[diplomat::rust_link(std::fmt::Display, Trait)]
    pub struct ControllerError(pub String);

    impl ControllerError {
        /// Gets the error message
        pub fn message(&self, result: &mut DiplomatWrite) -> Result<(), Box<ControllerError>> {
            write!(result, "{}", self.0).unwrap();
            Ok(())
        }

        /// Gets the error message as a string (for Python bindings)
        /// This always returns Ok so the error message can be extracted
        pub fn get_message_string(&self, result: &mut DiplomatWrite) {
            write!(result, "{}", self.0).unwrap();
        }
    }

    impl From<Utf8Error> for Box<ControllerError> {
        fn from(e: Utf8Error) -> Self {
            Box::new(ControllerError(e.to_string()))
        }
    }

    impl From<FromStrError> for Box<ControllerError> {
        fn from(e: FromStrError) -> Self {
            Box::new(ControllerError(e.to_string()))
        }
    }

    impl From<ParseError> for Box<ControllerError> {
        fn from(e: ParseError) -> Self {
            Box::new(ControllerError(e.to_string()))
        }
    }

    impl From<ControllerError> for String {
        fn from(e: ControllerError) -> Self {
            e.0
        }
    }

    impl std::fmt::Display for ControllerError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "{}", self.0)
        }
    }

    impl std::fmt::Debug for ControllerError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            write!(f, "{}", self.0)
        }
    }

    impl std::error::Error for ControllerError {}
}
