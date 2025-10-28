use lazy_static::lazy_static;
use tokio::runtime::Runtime;

lazy_static! {
    /// Global multi-threaded Tokio runtime
    /// This is created once and reused throughout the application to avoid
    /// the overhead of creating new runtimes and to prevent UI freezing
    pub static ref RUNTIME: Runtime = {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to create Tokio runtime")
    };
}
