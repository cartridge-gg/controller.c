#[diplomat::bridge]
pub mod ffi {
    use starknet_crypto::{get_public_key, Felt};

    use crate::{
        error::ffi::ControllerError, felt::ffi::DiplomatFelt, signer::ffi::DiplomatSigner,
        types::ffi::ResponseDataOut,
    };

    #[diplomat::opaque]
    pub struct Utils;

    impl Utils {
        pub fn subscribe_create_session(
            session_key_guid: &DiplomatFelt,
            cartridge_api_url: &str,
        ) -> Result<Box<ResponseDataOut>, Box<ControllerError>> {
            println!("session_key_guid {:?}", session_key_guid);
            tokio::runtime::Builder::new_current_thread()
                .enable_all()
                .build()
                .expect("Failed to create Tokio runtime")
                .block_on(account_sdk::session::subscribe_create_session(
                    session_key_guid.into(),
                    cartridge_api_url.to_string(),
                ))
                .map(|x| Box::new(ResponseDataOut { data: x }))
                .map_err(|e| {
                    Box::new(ControllerError(format!(
                        "Failed to subscribe {}",
                        e.to_string()
                    )))
                })
        }

        pub fn signer_to_guid(signer: &DiplomatSigner) -> Box<DiplomatFelt> {
            let signer: account_sdk::signers::Signer = signer.into();
            let guid: Felt = signer.into();
            Box::new(DiplomatFelt(guid))
        }

        pub fn get_public_key(private_key: &DiplomatFelt) -> Box<DiplomatFelt> {
            Box::new(DiplomatFelt(get_public_key(&private_key.into())))
        }
    }
}
