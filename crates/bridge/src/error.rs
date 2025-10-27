// Error enum
#[derive(Debug, thiserror::Error)]
pub enum ControllerError {
    #[error("Initialization error: {0}")]
    InitializationError(String),
    #[error("Signup error: {0}")]
    SignupError(String),
    #[error("Execution error: {0}")]
    ExecutionError(String),
    #[error("Network error: {0}")]
    NetworkError(String),
    #[error("Storage error: {0}")]
    StorageError(String),
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    #[error("Disconnect error: {0}")]
    DisconnectError(String),
}
