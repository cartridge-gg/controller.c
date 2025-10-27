# Controller UniFFI Bindings

Multi-language bindings for the Cartridge Controller SDK using UniFFI.

## Overview

This project provides language bindings for the Cartridge Controller SDK, enabling developers to interact with Starknet accounts and sessions from Python, Swift, Kotlin, C++, C#, and Go.

## Supported Languages

- ✅ **Python** - Fully functional
- ✅ **Swift** - Fully functional  
- ✅ **Kotlin** - Fully functional
- ✅ **C++** - Fully functional
- 🚧 **C#** - Basic support (requires uniffi-bindgen-cs)
- 🚧 **Go** - Basic support (requires uniffi-bindgen-go)

## Features

### Controller
- Account creation (standard and headless mode)
- Storage persistence (load from storage)
- User signup with Webauthn or Starknet signers
- Transaction execution
- Chain switching
- Token transfers
- Account delegation
- Error tracking

### SessionAccount
- Session-based authentication
- Transaction execution with session permissions
- Outside execution support
- Policy-based access control

## Building

### Prerequisites
```bash
# Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build the Rust library
cargo build --release
```

### Generate Bindings

```bash
# Python
./scripts/build_python.sh

# Swift
./scripts/build_swift.sh

# Kotlin
./scripts/build_kotlin.sh

# C++
cargo run --bin uniffi-bindgen-cpp
```

## Usage Examples

### Python

```python
from controller_uniffi import Owner, Controller, SignerType

# Create an owner
owner = Owner("0x1234...")

# Create a controller
controller = Controller(
    app_id="my_app",
    username="user123",
    class_hash="0x...",
    rpc_url="https://api.cartridge.gg/x/starknet/sepolia",
    owner=owner,
    address="0x...",
    chain_id="0x534e5f5345504f4c4941"
)

# Get controller info
print(f"Address: {controller.address()}")
print(f"Username: {controller.username()}")

# Execute a transaction
from controller_uniffi import Call

call = Call(
    contract_address="0x...",
    entrypoint="transfer",
    calldata=["0x...", "0x100"]
)

tx_hash = controller.execute([call])
print(f"Transaction hash: {tx_hash}")
```

### Swift

```swift
import ControllerSDK

// Create an owner
let owner = try Owner(privateKey: "0x1234...")

// Create a controller
let controller = try Controller(
    appId: "my_app",
    username: "user123",
    classHash: "0x...",
    rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
    owner: owner,
    address: "0x...",
    chainId: "0x534e5f5345504f4c4941"
)

// Get controller info
print("Address: \(try controller.address())")
print("Username: \(try controller.username())")
```

### Kotlin

```kotlin
import com.cartridge.controller.*

// Create an owner
val owner = Owner("0x1234...")

// Create a controller
val controller = Controller(
    appId = "my_app",
    username = "user123",
    classHash = "0x...",
    rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia",
    owner = owner,
    address = "0x...",
    chainId = "0x534e5f5345504f4c4941"
)

// Get controller info
println("Address: ${controller.address()}")
println("Username: ${controller.username()}")
```

### C++

```cpp
#include "controller.hpp"
#include <iostream>

int main() {
    // Create an owner
    auto owner = controller::Owner("0x1234...");

    // Create a controller
    auto ctrl = controller::Controller(
        "my_app",        // app_id
        "user123",       // username
        "0x...",         // class_hash
        "https://api.cartridge.gg/x/starknet/sepolia",  // rpc_url
        owner,           // owner
        "0x...",         // address
        "0x534e5f5345504f4c4941"  // chain_id
    );

    // Get controller info
    std::cout << "Address: " << ctrl.address() << std::endl;
    std::cout << "Username: " << ctrl.username() << std::endl;

    // Execute a transaction
    controller::Call call{
        "0x...",         // contract_address
        "transfer",      // entrypoint
        {"0x...", "0x100"}  // calldata
    };

    auto tx_hash = ctrl.execute({call});
    std::cout << "Transaction hash: " << tx_hash << std::endl;

    return 0;
}
```

To compile and link:
```bash
g++ -std=c++17 my_app.cpp -I./bindings/cpp -L./target/release -lcontroller_uniffi -o my_app
```

## Architecture

The project uses UniFFI to generate FFI bindings from Rust:

```
┌─────────────────────┐
│   Rust Core         │
│   (account_sdk)     │
└──────────┬──────────┘
           │
           │ UniFFI
           │
    ┌──────┴──────┬──────────┬──────────┬──────────┬──────────┐
    │             │          │          │          │          │
┌───▼───┐   ┌────▼────┐ ┌───▼────┐ ┌───▼────┐ ┌───▼────┐ ┌──▼───┐
│Python │   │  Swift  │ │ Kotlin │ │   C++  │ │   C#   │ │  Go  │
└───────┘   └─────────┘ └────────┘ └────────┘ └────────┘ └──────┘
```

## Project Structure

```
controller.c/
├── crates/
│   └── bridge/          # UniFFI bridge crate
│       ├── src/
│       │   ├── lib.rs          # Main library entry
│       │   ├── uniffi_impl.rs  # UniFFI implementations
│       │   ├── controller.udl  # UniFFI interface definition
│       │   └── bin/            # Bindgen binaries
│       ├── Cargo.toml
│       └── uniffi.toml         # UniFFI configuration
├── bindings/           # Generated bindings
│   ├── python/
│   ├── swift/
│   ├── kotlin/
│   ├── cpp/
│   ├── csharp/
│   └── go/
├── examples/          # Example usage
│   ├── python/
│   └── cpp/
└── scripts/           # Build scripts
```

## Development

### Running Tests

```bash
# Python example
cd examples/python
python3 test_controller.py
```

### Adding New Functionality

1. Update `uniffi_impl.rs` with new Rust implementations
2. Rebuild the library: `cargo build --release`
3. Regenerate bindings: `./scripts/build_*.sh`
4. Test in your target language

## Migration from Diplomat

This project was converted from Diplomat to UniFFI for better cross-language support and maintenance. Key differences:

- **Before (Diplomat):** Manual FFI definitions per language
- **After (UniFFI):** Single UDL + Rust procmacros generate all bindings
- **Benefit:** Easier to maintain, more languages supported

## License

MIT

## Contributing

Contributions are welcome! Please ensure:
1. Rust code compiles without warnings
2. All language bindings generate successfully
3. Examples run correctly

## Resources

- [UniFFI Documentation](https://mozilla.github.io/uniffi-rs/)
- [Cartridge Controller](https://github.com/cartridge-gg/controller-rs)
- [Starknet](https://starknet.io)
- [uniffi-bindgen-cpp Fork](https://github.com/Larkooo/uniffi-bindgen-cpp)
