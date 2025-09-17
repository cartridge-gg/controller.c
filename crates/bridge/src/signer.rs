#[diplomat::bridge]
pub mod ffi {
    use starknet::signers::SigningKey;
    use starknet_crypto::Felt;

    use crate::{error::ffi::ControllerError, felt::ffi::DiplomatFelt};

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
    pub struct DiplomatSigner(pub account_sdk::signers::Signer);

    impl DiplomatSigner {
        pub fn new_starknet_signer(secret_scalar: &DiplomatFelt) -> Box<DiplomatSigner> {
            Box::new(DiplomatSigner(account_sdk::signers::Signer::Starknet(
                SigningKey::from_secret_scalar(secret_scalar.into()),
            )))
        }
    }

    impl DiplomatOwner {
        pub fn new_from_starknet_signer(
            starknet_pk: &DiplomatStr,
        ) -> Result<Box<DiplomatOwner>, Box<ControllerError>> {
            let starknet_signer = SigningKey::from_secret_scalar(
                Felt::from_hex(std::str::from_utf8(starknet_pk).unwrap())
                    .map_err(|e| Box::new(ControllerError(e.to_string())))?,
            );
            let signer = account_sdk::signers::Signer::Starknet(starknet_signer);
            Ok(Box::new(DiplomatOwner(
                account_sdk::signers::Owner::Signer(signer),
            )))
        }
    }

    impl From<DiplomatSigner> for account_sdk::signers::Signer {
        fn from(value: DiplomatSigner) -> Self {
            value.0
        }
    }
    impl From<&DiplomatSigner> for account_sdk::signers::Signer {
        fn from(value: &DiplomatSigner) -> Self {
            value.0.clone()
        }
    }

    impl From<DiplomatSigner> for account_sdk::abigen::controller::Signer {
        fn from(value: DiplomatSigner) -> Self {
            value.0.into()
        }
    }
    impl From<&DiplomatSigner> for account_sdk::abigen::controller::Signer {
        fn from(value: &DiplomatSigner) -> Self {
            value.0.clone().into()
        }
    }
    impl From<&DiplomatSigner> for DiplomatFelt {
        fn from(value: &DiplomatSigner) -> Self {
            DiplomatFelt(value.0.clone().into())
        }
    }
}
