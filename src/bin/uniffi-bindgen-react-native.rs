use std::{env, process};

use camino::Utf8PathBuf;

const HELP_TEXT: &str = r#"
UniFFI React Native Binding Generator for controller.c

DESCRIPTION:
    This tool generates React Native (TypeScript + C++) bindings from the
    controller-uniffi Rust library using uniffi-bindgen-react-native.

    The generated bindings enable direct JSI (JavaScript Interface) communication
    between React Native and the Rust core, providing high-performance native
    access without the traditional bridge overhead.

USAGE:
    cargo run --bin uniffi-bindgen-react-native [library_path] [output_dir]

ARGUMENTS:
    library_path    Path to the compiled Rust library
                    Default: target/release/libcontroller_uniffi.{dylib,so,dll}

    output_dir      Output directory for generated bindings
                    Default: bindings/react-native

PREREQUISITES:
    1. Install uniffi-bindgen-react-native:

       cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native \
           --branch update-uniffi-0.30 uniffi-bindgen-react-native

    2. Build the Rust library first:

       cargo build --release -p controller-uniffi

EXAMPLES:
    # Use default paths (recommended)
    cargo run --bin uniffi-bindgen-react-native

    # Specify custom paths
    cargo run --bin uniffi-bindgen-react-native \
        target/release/libcontroller_uniffi.dylib \
        bindings/react-native

    # Or use the convenience script (recommended):
    ./scripts/build_react_native.sh

OUTPUT STRUCTURE:
    bindings/react-native/
    ├── src/                  # TypeScript bindings
    │   ├── controller.ts     # Main generated API
    │   ├── controller-ffi.ts # FFI layer
    │   └── ...
    └── cpp/                  # C++ bindings  
        ├── controller.hpp    # Header file
        ├── controller.cpp    # Implementation
        └── generated/        # Additional generated files

WORKFLOW:
    After generating bindings, copy them to your React Native project:

    # TypeScript bindings
    cp -r bindings/react-native/src/* your-app/modules/controller/src/generated/

    # C++ bindings
    cp -r bindings/react-native/cpp/* your-app/modules/controller/cpp/generated/

    Or use the convenience script which handles everything:

    ./scripts/build_react_native.sh

SEE ALSO:
    - ./scripts/build_react_native.sh    Full build script with Android support
    - ./scripts/build_android.sh         Build Android native libraries only
    - examples/react-native/README.md    React Native example documentation
"#;

fn main() {
    let args: Vec<String> = env::args().collect();

    // Show help if requested
    if args.len() > 1 && (args[1] == "--help" || args[1] == "-h") {
        eprintln!("{}", HELP_TEXT);
        process::exit(0);
    }

    // Check if uniffi-bindgen-react-native is installed
    if which::which("uniffi-bindgen-react-native").is_err() {
        eprintln!("Error: uniffi-bindgen-react-native is not installed or not in PATH");
        eprintln!();
        eprintln!("Please install it with:");
        eprintln!("  cargo install --git https://github.com/Larkooo/uniffi-bindgen-react-native \\");
        eprintln!("      --branch update-uniffi-0.30 uniffi-bindgen-react-native");
        eprintln!();
        eprintln!("Or add it to your PATH if already installed.");
        eprintln!();
        eprintln!("Run with --help for more information.");
        process::exit(1);
    }

    // Determine library extension based on platform
    let lib_ext = if cfg!(target_os = "macos") {
        "dylib"
    } else if cfg!(target_os = "windows") {
        "dll"
    } else {
        "so"
    };

    // Default paths
    let default_lib = format!("target/release/libcontroller_uniffi.{}", lib_ext);
    let default_out = "bindings/react-native";

    // Parse arguments
    let positional_args: Vec<&String> = args
        .iter()
        .skip(1)
        .filter(|arg| !arg.starts_with("--"))
        .collect();

    let library_path = Utf8PathBuf::from(
        positional_args
            .first()
            .map(|s| s.as_str())
            .unwrap_or(&default_lib),
    );
    let out_dir = Utf8PathBuf::from(
        positional_args
            .get(1)
            .map(|s| s.as_str())
            .unwrap_or(default_out),
    );

    if !library_path.exists() {
        eprintln!("Error: Library file not found: {}", library_path);
        eprintln!("Build the library first with: cargo build --release -p controller-uniffi");
        eprintln!();
        eprintln!("Hint: Run with --help to see usage information");
        process::exit(1);
    }

    // Create output directory if it doesn't exist
    if let Err(e) = std::fs::create_dir_all(&out_dir) {
        eprintln!(
            "Error: Failed to create output directory {}: {}",
            out_dir, e
        );
        process::exit(1);
    }

    // Create ts and cpp subdirectories
    let ts_dir = out_dir.join("src");
    let cpp_dir = out_dir.join("cpp");

    if let Err(e) = std::fs::create_dir_all(&ts_dir) {
        eprintln!("Error: Failed to create TypeScript directory {}: {}", ts_dir, e);
        process::exit(1);
    }
    if let Err(e) = std::fs::create_dir_all(&cpp_dir) {
        eprintln!("Error: Failed to create C++ directory {}: {}", cpp_dir, e);
        process::exit(1);
    }

    println!("Generating React Native bindings...");
    println!("Library:    {}", library_path);
    println!("TypeScript: {}", ts_dir);
    println!("C++:        {}", cpp_dir);

    // Build command for uniffi-bindgen-react-native
    // New CLI: uniffi-bindgen-react-native generate jsi bindings --library --ts-dir <DIR> --cpp-dir <DIR> <SOURCE>
    let mut cmd = process::Command::new("uniffi-bindgen-react-native");
    cmd.args(["generate", "jsi", "bindings"]);
    cmd.arg("--library");
    cmd.arg("--ts-dir").arg(&ts_dir);
    cmd.arg("--cpp-dir").arg(&cpp_dir);
    cmd.arg(&library_path);

    // Execute the command
    match cmd.output() {
        Ok(output) => {
            if output.status.success() {
                println!("✓ React Native bindings generated successfully!");

                if !output.stdout.is_empty() {
                    println!("{}", String::from_utf8_lossy(&output.stdout));
                }
            } else {
                eprintln!("Error generating bindings:");
                if !output.stderr.is_empty() {
                    eprintln!("{}", String::from_utf8_lossy(&output.stderr));
                }
                if !output.stdout.is_empty() {
                    eprintln!("{}", String::from_utf8_lossy(&output.stdout));
                }
                process::exit(1);
            }
        }
        Err(e) => {
            eprintln!("Error executing uniffi-bindgen-react-native: {}", e);
            process::exit(1);
        }
    }
}
