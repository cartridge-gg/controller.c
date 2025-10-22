# Python Controller Complete Test Suite

Complete Python test suite for the Controller UniFFI bindings with full workflows.

## Quick Start

```bash
./run.sh
```

This will automatically:
1. Build the Rust library if needed
2. Generate Python bindings if needed
3. Run the complete test suite

## Manual Usage

### 1. Build the Rust library

```bash
cd ../..
cargo build --release
```

### 2. Generate Python bindings

```bash
./scripts/build_python.sh
```

### 3. Run the tests

```bash
cd examples/python
python3 test_complete.py
```

## What's Tested

The `test_complete.py` file tests all functionality with complete workflows:

### Step 1: Utility Functions
- `validate_felt()` - Validate field element strings
- `get_public_key()` - Derive public key from private key
- `signer_to_guid()` - Convert signer to GUID
- `get_controller_class_hash()` - Get controller class hash by version

### Step 2: Owner Creation
- `Owner(private_key)` - Create owner from private key

### Step 3: Controller Creation
- `Controller.new_headless()` - Create headless controller
- Get controller information: `address()`, `username()`, `app_id()`, `chain_id()`

### Step 4: Controller Storage
- `controller_has_storage()` - Check if storage exists
- `Controller.from_storage()` - Load from storage

### Step 5: Signup
- `controller.signup()` - Sign up the controller with the network

### Step 6: Transaction Execution
- `controller.execute()` - Execute transactions

### Step 7: Transfer
- `controller.transfer()` - Simplified ETH transfer

### Step 8: SessionAccount Creation
- `SessionAccount()` - Create session account with policies

### Step 9: SessionAccount from API
- `SessionAccount.create_from_subscribe()` - Create from GraphQL API

### Step 10: Session Execution
- `session.execute()` - Execute with session account

### Step 11: Error Handling
- Error catching and `error_message()` / `clear_last_error()`

## Example Usage

```python
import sys
from pathlib import Path

# Setup paths
sys.path.insert(0, str(Path("../../bindings/python")))

from controller_uniffi import (
    Owner,
    Controller,
    Version,
    get_controller_class_hash,
)

# Create owner
owner = Owner("0x...")

# Get latest controller class hash
class_hash = get_controller_class_hash(Version.LATEST)

# Create headless controller
controller = Controller.new_headless(
    app_id="my_app",
    username="my_user",
    class_hash=class_hash,
    rpc_url="https://api.cartridge.gg/x/starknet/sepolia",
    owner=owner,
    chain_id="0x534e5f5345504f4c4941"
)

# Get controller info
address = controller.address()
username = controller.username()

print(f"Controller: {username} at {address}")
```

## Requirements

- Python 3.8+
- Rust and Cargo (to build the library)

## Troubleshooting

**ModuleNotFoundError:**
Make sure you've run `./scripts/build_python.sh` from the project root.

**Library not found:**
Build the Rust library first: `cargo build --release`

**Expected Test Failures:**
Some operations (signup, execute, transfer) are expected to fail in the test environment because:
- Accounts are not deployed
- Accounts have no funds
- No real API connection

These failures are normal and expected - they demonstrate that the bindings are working correctly by properly propagating errors from the Rust layer.
