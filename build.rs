use std::env;
use std::path::PathBuf;

fn main() {
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    let out_dir = PathBuf::from(&crate_dir);

    // Generate C bindings
    let config = cbindgen::Config {
        language: cbindgen::Language::C,
        cpp_compat: true,
        include_guard: Some("CONTROLLER_C_H".to_string()),
        pragma_once: true,
        documentation: true,
        documentation_style: cbindgen::DocumentationStyle::C99,
        export: cbindgen::ExportConfig {
            include: vec![
                "controller_*".to_string(),
                "session_*".to_string(),
                "result_*".to_string(),
                "string_*".to_string(),
            ],
            ..Default::default()
        },
        ..Default::default()
    };

    cbindgen::Builder::new()
        .with_crate(&crate_dir)
        .with_config(config)
        .generate()
        .expect("Unable to generate C bindings")
        .write_to_file(out_dir.join("controller.h"));

    // Generate C++ bindings
    let cpp_config = cbindgen::Config {
        language: cbindgen::Language::Cxx,
        namespace: Some("controller".to_string()),
        include_guard: Some("CONTROLLER_CPP_H".to_string()),
        pragma_once: true,
        documentation: true,
        documentation_style: cbindgen::DocumentationStyle::Cxx,
        export: cbindgen::ExportConfig {
            include: vec![
                "controller_*".to_string(),
                "session_*".to_string(),
                "result_*".to_string(),
                "string_*".to_string(),
            ],
            ..Default::default()
        },
        ..Default::default()
    };

    cbindgen::Builder::new()
        .with_crate(&crate_dir)
        .with_config(cpp_config)
        .generate()
        .expect("Unable to generate C++ bindings")
        .write_to_file(out_dir.join("controller_raw.hpp"));

    println!("cargo:rerun-if-changed=src/lib.rs");
    println!("cargo:rerun-if-changed=build.rs");
}
