#[diplomat::bridge]
pub mod ffi {
    use account_sdk::graphql::session::subscribe_create_session;
    use std::fmt::Write;

    use crate::error::ffi::ControllerError;

    #[diplomat::opaque]
    pub struct SubscribeCreateSessionResponse(pub subscribe_create_session::ResponseData);

    impl SubscribeCreateSessionResponse {
        pub fn get_as_json(
            &self,
            writeable: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            if let Some(session) = &self.0.subscribe_create_session {
                let json = serde_json::to_string_pretty(session)
                    .map_err(|e| Box::new(ControllerError(e.to_string())))?;
                write!(writeable, "{}", json).unwrap();
            }
            Ok(())
        }
    }
}
