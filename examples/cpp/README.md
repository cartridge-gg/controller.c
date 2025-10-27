# C++ Controller Examples

Complete C++ test suite for the Controller UniFFI bindings, demonstrating all functionality similar to the Swift test suite.

## Quick Start

### Run the Complete Test Suite

```bash
./run.sh
```

This will:
1. Build the `controller-uniffi` library
2. Compile the C++ test with CMake
3. Run all tests

## What Gets Tested

The test suite (`controller_test.cpp`) demonstrates and tests:

### ✅ Step 1: Utility Functions
- `validate_felt()` - Validate field elements
- `get_public_key()` - Derive public key from private key
- `signer_to_guid()` - Convert signer to GUID
- `get_controller_class_hash()` - Get controller class hashes for different versions

### ✅ Step 2: Owner Creation
- Create an `Owner` from a private key

### ✅ Step 3: Controller Creation
- Create a headless controller
- Display controller information (address, username, app ID, chain ID)

### ✅ Step 4: Controller Storage
- Check if controller has storage
- Test storage retrieval

### ⚠️ Step 5: Signup
- Test controller signup (may fail if not funded)

### ⚠️ Step 6: Transaction Execution
- Execute a transaction (may fail if account not deployed)

### ⚠️ Step 7: Transfer
- Transfer tokens (may fail if account not deployed)

### ✅ Step 8: SessionAccount
- Create a session account with policies

### ⚠️ Step 9: SessionAccount from API
- Create session from GraphQL API (may fail without real session)

### ⚠️ Step 10: Session Execution
- Execute transactions with session

### ✅ Step 11: Error Handling
- Test error catching and error messages
- Verify error clearing

## Expected Behavior

Some tests are **expected to fail** in a test environment:
- ⚠️ Signup (account may already exist or not be funded)
- ⚠️ Transaction execution (account not deployed)
- ⚠️ Transfer (account not deployed)
- ⚠️ Session API creation (requires real session)

These failures are **normal** and indicated with warnings in the output.

## Example Output

```
======================================================================
  🚀 COMPLETE CONTROLLER-UNIFFI C++ TEST SUITE
  Testing all functionality with full workflows
======================================================================

=== Step 1: Testing Utility Functions ===
✓ validate_felt: works
✓ get_public_key: 0x36d65c8c6785a6bbc6...
✓ signer_to_guid: 0x589a6079a32352b82d...
✓ get_controller_class_hash(kV109): 0x743c83c41ce99ad470...
✓ get_controller_class_hash(kLatest): 0x743c83c41ce99ad470...

=== Step 2: Creating Owner ===
🔑 Using private key: 0x77bef600f1995da09e...
✓ Owner created successfully

=== Step 3: Creating Controller ===
📋 Getting controller class hash...
📄 Class hash: 0x743c83c41ce99ad470aa...
🎮 Creating headless controller...
✓ Controller created successfully

📊 Controller Information:
  📍 Address: 0x15a0f6b976af83918bf71248ba8bdb8f012da31b9912da909e4da5e56aeb83
  👤 Username: cppuser-71484016
  🆔 App ID: test_app_cpp
  ⛓️  Chain ID: 0x534e5f5345504f4c4941

...

======================================================================
  ✅ ALL TESTS COMPLETED
  All modules and workflows tested!
======================================================================
```

## Building Manually

### Prerequisites
- C++20 compiler (GCC 10+, Clang 10+, or MSVC 2019+)
- CMake 3.20+
- Rust toolchain (for building the library)

### Build Steps

```bash
# 1. Build the library
cd ../..
cargo build --release -p controller-uniffi

# 2. Configure and build the test
cd examples/cpp
mkdir -p build
cd build
cmake ..
cmake --build .

# 3. Run
./controller_test
```

## Code Structure

```
controller.c/examples/cpp/
├── controller_test.cpp    # Complete test suite (460 lines)
├── CMakeLists.txt         # CMake build configuration
├── run.sh                 # Automated build and run script
└── README.md              # This file
```

## Using the Bindings in Your Project

### CMake Integration

```cmake
cmake_minimum_required(VERSION 3.20)
project(my_controller_app)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(my_app
    main.cpp
    /path/to/controller.c/bindings/cpp/controller.cpp
)

target_include_directories(my_app PRIVATE
    /path/to/controller.c/bindings/cpp
)

if(APPLE)
    target_link_libraries(my_app
        /path/to/controller.c/target/release/libcontroller_uniffi.dylib
    )
elseif(UNIX)
    target_link_libraries(my_app
        /path/to/controller.c/target/release/libcontroller_uniffi.so
    )
endif()
```

### Simple Example

```cpp
#include <iostream>
#include "controller.hpp"

int main() {
    try {
        // Create owner
        auto owner = controller::Owner::init(
            "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        );
        
        // Get controller class hash
        auto classHash = controller::get_controller_class_hash(
            controller::Version::kLatest
        );
        
        // Create headless controller
        auto ctrl = controller::Controller::new_headless(
            "my_app",
            "my_username",
            classHash,
            "https://api.cartridge.gg/x/starknet/sepolia",
            owner,
            "0x534e5f5345504f4c4941"
        );
        
        std::cout << "Controller address: " << ctrl->address() << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
```

## API Reference

### Key Types

- `controller::Owner` - Controller owner (signer)
- `controller::Controller` - Main controller interface
- `controller::SessionAccount` - Session-based account
- `controller::Call` - Transaction call structure
- `controller::SessionPolicies` - Session authorization policies

### Enums

- `controller::Version` - Controller versions (`kV104`, `kV105`, ..., `kLatest`)
- `controller::SignerType` - Signer types (`kWebauthn`, `kStarknet`)

### Key Functions

```cpp
// Utility functions
std::string validate_felt(const std::string& felt);
std::string get_public_key(const std::string& private_key);
std::string signer_to_guid(const std::string& private_key);
std::string get_controller_class_hash(Version version);
bool controller_has_storage(const std::string& app_id);

// Owner methods
std::shared_ptr<Owner> Owner::init(const std::string& private_key);

// Controller methods
std::shared_ptr<Controller> Controller::new_headless(...);
std::shared_ptr<Controller> Controller::from_storage(const std::string& app_id);
std::string address();
std::string username();
void signup(...);
std::string execute(const std::vector<Call>& calls);
std::string transfer(const std::string& recipient, const std::string& amount);

// SessionAccount methods
std::shared_ptr<SessionAccount> SessionAccount::init(...);
std::shared_ptr<SessionAccount> SessionAccount::create_from_subscribe(...);
std::string execute(const std::vector<Call>& calls);
```

## Error Handling

The bindings use C++ exceptions for error handling:

```cpp
try {
    auto ctrl = controller::Controller::from_storage("my_app");
} catch (const std::exception& e) {
    std::cerr << "Error: " << e.what() << std::endl;
    
    // Get more detailed error message from controller
    if (ctrl) {
        auto errorMsg = ctrl->error_message();
        std::cerr << "Details: " << errorMsg << std::endl;
        ctrl->clear_last_error();
    }
}
```

## Memory Management

All objects use `std::shared_ptr` for automatic memory management:
- No manual memory management required
- RAII-based cleanup
- Thread-safe reference counting

## Platform Support

- ✅ macOS (Intel & Apple Silicon)
- ✅ Linux (x86_64 & ARM64)
- ✅ Windows (x86_64)

## Troubleshooting

### Library Not Found
```bash
# macOS
export DYLD_LIBRARY_PATH=/path/to/controller.c/target/release:$DYLD_LIBRARY_PATH

# Linux
export LD_LIBRARY_PATH=/path/to/controller.c/target/release:$LD_LIBRARY_PATH
```

### Compilation Errors
- Ensure you're using C++20 or later
- Check that the library was built in release mode
- Verify include paths in CMakeLists.txt

### Runtime Errors
- Most signup/execution errors are expected in test environments
- Accounts need to be deployed and funded for real transactions
- Check the error messages for specific issues

## More Information

- See the full test suite in `controller_test.cpp` for detailed usage examples
- Check the Swift example (`../swift/controller.swift`) for similar patterns
- Refer to the Python example (`../python/controller.py`) for comparison

---

**Generated:** 2025-10-23  
**UniFFI Version:** 0.30  
**Tested on:** macOS with Clang


