#[diplomat::bridge]
pub mod ffi {
    use starknet::signers::SigningKey;
    use starknet_crypto::Felt;

    use crate::ffi::{ControllerError, ErrorType};

    pub enum OwnerType {
        Signer,
        Account,
    }

    /// Opaque wrapper for Owner type
    #[diplomat::opaque]
    #[diplomat::transparent_convert]
    pub struct DiplomatOwner(pub account_sdk::signers::Owner);

    /// Opaque wrapper for complex Signer type
    #[diplomat::opaque]
    pub struct DiplomatSigner {
        pub webauthn: Option<Box<WebauthnSigner>>,
        pub starknet: Option<Box<StarknetSigner>>,
        pub eip191: Option<Box<Eip191Signer>>,
    }

    /// Opaque wrapper for WebauthnSigner
    #[diplomat::opaque]
    pub struct WebauthnSigner {
        // Internal fields
    }

    /// Opaque wrapper for StarknetSigner  
    #[diplomat::opaque]
    pub struct StarknetSigner {
        pub private_key: String,
    }

    /// Opaque wrapper for Eip191Signer
    #[diplomat::opaque]
    pub struct Eip191Signer {
        // Internal fields
    }

    impl DiplomatOwner {
        pub fn new_from_starknet_signer(
            starknet_pk: &DiplomatStr,
        ) -> Result<Box<DiplomatOwner>, Box<ControllerError>> {
            let starknet_signer = SigningKey::from_secret_scalar(
                Felt::from_hex(std::str::from_utf8(starknet_pk).unwrap()).map_err(|e| {
                    Box::new(ControllerError {
                        error_type: ErrorType::InvalidInput,
                        message: format!("Invalid private key: {e}"),
                    })
                })?,
            );
            let signer = account_sdk::signers::Signer::Starknet(starknet_signer);
            Ok(Box::new(DiplomatOwner(
                account_sdk::signers::Owner::Signer(signer),
            )))
        }
    }
}
