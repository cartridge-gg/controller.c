#[diplomat::bridge]
pub mod ffi {
    use starknet_crypto::Felt;
    use tokio::runtime::Runtime;

    use crate::{
        error::ffi::{store_error, ControllerError},
        felt::ffi::DiplomatFelt,
        signer::ffi::DiplomatSigner,
        types::ffi::ResponseDataOut,
    };

    #[diplomat::opaque]
    pub struct Utils;

    impl Utils {
        pub fn subscribe_create_session(
            session_key_guid: &DiplomatFelt,
            cartridge_api_url: &str,
        ) -> Result<Box<ResponseDataOut>, Box<ControllerError>> {
            tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(account_sdk::session::subscribe_create_session(
                    session_key_guid.into(),
                    cartridge_api_url.to_string(),
                ))
                .map(|x| Box::new(ResponseDataOut { data: x }))
                .map_err(|e| store_error!(e))
        }

        pub fn signer_to_guid(signer: &DiplomatSigner) -> Box<DiplomatFelt> {
            let signer: account_sdk::signers::Signer = signer.into();
            let guid: Felt = signer.into();
            Box::new(DiplomatFelt(guid))
        }
    }
}
