#[diplomat::bridge]
pub mod ffi {
    use account_sdk::artifacts::CONTROLLERS as SDK_CONTROLLERS;
    use diplomat_runtime::DiplomatWrite;
    use std::fmt::Write;

    use crate::error::ffi::ControllerError;

    #[diplomat::opaque]
    pub struct CONTROLLERS(pub SDK_CONTROLLERS);

    #[diplomat::enum_convert(account_sdk::artifacts::Version)]
    pub enum Version {
        V1_0_4,
        V1_0_5,
        V1_0_6,
        V1_0_7,
        V1_0_8,
        V1_0_9,
        LATEST,
    }

    impl CONTROLLERS {
        pub fn get_class_hash(
            version: Version,
            write: &mut DiplomatWrite,
        ) -> Result<(), Box<ControllerError>> {
            let sdk_version: account_sdk::artifacts::Version = (version).into();
            let class_hash = SDK_CONTROLLERS
                .get(&sdk_version)
                .ok_or_else(|| Box::new(ControllerError("Version not found".to_string())))?;
            let _ = write!(write, "{:#x}", class_hash.hash);
            Ok(())
        }
    }

    #[diplomat::enum_convert(account_sdk::signers::types::SignerType, needs_wildcard)]
    pub enum SignerType {
        Starknet,
        StarknetAccount,
        Eip191,
        Webauthn,
        Siws,
        Secp256k1,
        Secp256r1,
    }
}
