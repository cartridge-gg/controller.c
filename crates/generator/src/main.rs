use std::path::Path;

use diplomat_tool::{
    config::{Config, SharedConfig},
    DocsUrlGenerator,
};

pub fn main() {
    diplomat_tool::gen(
        Path::new("crates/bridge/src/lib.rs"),
        "py-nanobind",
        Path::new("bindings/py"),
        &DocsUrlGenerator::default(),
        Config {
            shared_config: SharedConfig {
                lib_name: Some("controller_c".to_string()),
                ..Default::default()
            },
            ..Config::default()
        },
        false,
    )
    .unwrap();
}
