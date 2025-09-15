use std::{
    env::{self},
    path::Path,
};

use diplomat_tool::{
    config::{Config, SharedConfig},
    DocsUrlGenerator,
};

pub fn main() {
    let target_language = env::args().collect::<Vec<_>>()[1].to_ascii_lowercase();

    if target_language != "py" && target_language != "c" && target_language != "js" {
        panic!("expected py/js/c/demo_gen")
    }

    let formatted = String::from(format!("bindings/{}", target_language.clone()));
    let out_folder = Path::new(&formatted);

    diplomat_tool::gen(
        Path::new("crates/bridge/src/lib.rs"),
        if target_language.eq("py") {
            "py-nanobind"
        } else {
            &target_language
        },
        out_folder,
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
