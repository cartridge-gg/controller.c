#[diplomat::bridge]
pub mod ffi {
    use account_sdk::graphql::session::subscribe_create_session;

    #[diplomat::opaque]
    pub struct SubscribeCreateSessionResponse(pub subscribe_create_session::ResponseData);

    #[diplomat::opaque]
    pub struct ResponseDataOut {
        pub data: subscribe_create_session::ResponseData,
    }
}
