# controller.c

C and C++ bindings for the Controller SDK, following the pattern established by [dojo.c](https://github.com/dojoengine/dojo.c).

This package provides a C-compatible interface to the Controller Rust library, enabling integration with C/C++ applications and other languages that support C FFI.

## Features

- Complete C bindings for Controller functionality
- Modern C++ wrapper with RAII and exception handling
- Cross-platform support (Linux, macOS, Windows)
- Automatic header generation using cbindgen
- Comprehensive examples in both C and C++

## Building

### Prerequisites

- Rust toolchain (stable)
- C/C++ compiler (clang, gcc, or MSVC)
- Make (for building examples)

### Build Instructions

```bash
# Clone the repository
git clone https://github.com/yourusername/controller.c
cd controller.c

# Build the library
cargo build --release

# Build examples (Unix-like systems)
cd example
make all
```

### Cross-compilation

For cross-compilation to different targets:

```bash
# Install cross
cargo install cross

# Build for specific target
cross build --release --target x86_64-unknown-linux-gnu
```

## Usage

### C Example

```c
#include "controller.h"

int main() {
    // Create controller
    CController* controller = controller_new(
        "http://localhost:5050",
        "0x1234...",
        "0xabcd..."
    );

    // Create session with policies
    CPolicy policies[] = {
        { .target = "0x1111...", .method = "transfer" },
        { .target = "0x2222...", .method = "approve" }
    };

    CSession* session = controller_create_session(
        controller,
        policies,
        2,
        time(NULL) + 86400
    );

    // Use session...

    // Clean up
    session_free(session);
    controller_free(controller);

    return 0;
}
```

### C++ Example

```cpp
#include "controller.hpp"
#include <vector>

using namespace controller;

int main() {
    try {
        // Create controller
        Controller ctrl(
            "http://localhost:5050",
            "0x1234...",
            "0xabcd..."
        );

        // Create session with policies
        std::vector<Policy> policies = {
            Policy("0x1111...", "transfer"),
            Policy("0x2222...", "approve")
        };

        Session session = ctrl.create_session(policies, time(nullptr) + 86400);

        // Use session...

    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
```

## API Reference

### C API

#### Controller Management

- `controller_new()` - Create a new controller instance
- `controller_free()` - Free a controller instance

#### Session Management

- `controller_create_session()` - Create a new session with policies
- `controller_get_session()` - Retrieve a session by address
- `controller_revoke_session()` - Revoke an existing session
- `session_free()` - Free a session instance

#### Utility Functions

- `result_free()` - Free a result structure
- `string_free()` - Free a C string

### C++ API

The C++ wrapper provides RAII-compliant classes:

- `Controller` - Main controller class
- `Session` - Session representation
- `Policy` - Policy for session creation
- `Result` - Operation result with error handling

## Project Structure

```
controller.c/
├── src/
│   └── lib.rs          # Rust FFI implementation
├── example/
│   ├── main.c          # C example
│   ├── main.cpp        # C++ example
│   └── Makefile        # Build examples
├── controller.h        # C header (generated)
├── controller.hpp      # C++ wrapper
├── build.rs            # Build script
├── Cargo.toml          # Rust dependencies
└── README.md           # This file
```

## Platform Support

- **Linux**: Full support with `.so` shared libraries
- **macOS**: Full support with `.dylib` libraries
- **Windows**: Full support with `.dll` libraries
- **WebAssembly**: Planned support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

This project follows the architectural patterns established by [dojo.c](https://github.com/dojoengine/dojo.c).
