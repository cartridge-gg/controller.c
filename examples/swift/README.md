# Swift Controller Complete Test Suite

Complete Swift test suite for the Controller UniFFI bindings with full workflows.

## Prerequisites

- Xcode Command Line Tools or Xcode installed
- Swift 5.5 or later
- Rust and Cargo (to build the library)

## Building

1. **Build the Rust library:**
   ```bash
   cd ../..
   cargo build --release
   ```

2. **Generate Swift bindings:**
   ```bash
   ./scripts/build_swift.sh
   ```

## Running Tests

```bash
./run_test.sh
```

Or simply:
```bash
./run_test.sh
```

This will:
1. Compile the Swift test file with the generated bindings
2. Link against the Rust library
3. Run all tests
4. Clean up the compiled binary

## What's Tested

The `test_complete.swift` file tests all functionality with complete workflows:

### Step 1: Utility Functions
- `validateFelt()` - Validate field element strings
- `getPublicKey()` - Derive public key from private key
- `signerToGuid()` - Convert signer to GUID
- `getControllerClassHash()` - Get controller class hash by version

### Step 2: Owner Creation
- `Owner(privateKey:)` - Create owner from private key

### Step 3: Controller Creation
- `Controller.newHeadless()` - Create headless controller
- Get controller information: `address()`, `username()`, `appId()`, `chainId()`

### Step 4: Controller Storage
- `controllerHasStorage()` - Check if storage exists
- `Controller.fromStorage()` - Load from storage

### Step 5: Signup
- `controller.signup()` - Sign up the controller with the network

### Step 6: Transaction Execution
- `controller.execute()` - Execute transactions

### Step 7: Transfer
- `controller.transfer()` - Simplified ETH transfer

### Step 8: SessionAccount Creation
- `SessionAccount()` - Create session account with policies

### Step 9: SessionAccount from API
- `SessionAccount.createFromSubscribe()` - Create from GraphQL API

### Step 10: Session Execution
- `session.execute()` - Execute with session account

### Step 11: Error Handling
- Error catching and `errorMessage()` / `clearLastError()`

## Example Usage

```swift
import controller_uniffi

// Create owner
let owner = try Owner(privateKey: "0x...")

// Get latest controller class hash
let classHash = try getControllerClassHash(version: .latest)

// Create headless controller
let controller = try Controller.newHeadless(
    appId: "my_app",
    username: "my_user",
    classHash: classHash,
    rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
    owner: owner,
    chainId: "0x534e5f5345504f4c4941"
)

// Get controller info
let address = try controller.address()
let username = try controller.username()

print("Controller: \(username) at \(address)")
```

## Manual Compilation

If you want to compile manually:

```bash
swiftc \
    -I ../../bindings/swift \
    -L ../../target/release \
    -lcontroller_uniffi \
    -Xlinker -rpath -Xlinker ../../target/release \
    test_complete.swift \
    ../../bindings/swift/controller_uniffi.swift \
    -o test_complete

./test_complete
```

## Troubleshooting

**Library not found error:**
```bash
export DYLD_LIBRARY_PATH=../../target/release:$DYLD_LIBRARY_PATH
```

**Bindings not found:**
Make sure you've run `./scripts/build_swift.sh` from the project root.

**Compilation errors:**
Ensure you're using Swift 5.5+ and have Xcode Command Line Tools installed.

