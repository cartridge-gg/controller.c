# Controller Python Examples

This directory contains Python examples for the Controller SDK using nanobind bindings.

## Files

- `test_controller.py` - Main Python example demonstrating Controller usage
- `setup_and_run.sh` - **Main script** - Complete setup and run script (recommended)
- `setup_python.py` - Setup script to build and configure the nanobind bindings
- `run_python.py` - Runner script that handles path setup and execution
- `requirements.txt` - Python dependencies
- `README.md` - This file

## Virtual Environment

The setup script automatically creates and uses a Python virtual environment (`venv/`) to avoid conflicts with system packages. This is especially important on systems with externally managed Python environments (like Homebrew on macOS).

The virtual environment is created in `examples/python/venv/` and contains all the required Python dependencies.

## Script Options

The `setup_and_run.sh` script supports various options:

```bash
./setup_and_run.sh --help          # Show help
./setup_and_run.sh                 # Complete setup and run (default)
./setup_and_run.sh --no-run        # Setup everything but don't run
./setup_and_run.sh --clean         # Clean build artifacts
./setup_and_run.sh --deps-only     # Only install Python dependencies
./setup_and_run.sh --build-only    # Only build library and extension
./setup_and_run.sh --test-only     # Only test the installation
```

## Quick Start

### Option 1: One-Command Setup and Run

The easiest way to get started:

```bash
# From the project root
cd examples/python
./setup_and_run.sh
```

This script will:
1. Check prerequisites (Python 3.8+, Rust/Cargo)
2. Create and activate a Python virtual environment
3. Install Python dependencies in the virtual environment
4. Build the Rust library and generate bindings
5. Build the Python extension
6. Test the installation
7. Run the example

### Option 2: Manual Setup

If you prefer to run steps manually:

```bash
# From the project root
cd examples/python

# Install dependencies and build everything
./setup_and_run.sh --no-run

# Then run the example
python3 test_controller.py
```

### Option 3: Individual Steps

```bash
# 1. Build the library (from project root)
./scripts/build.sh

# 2. Create virtual environment and install dependencies
cd examples/python
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 3. Setup the bindings
python3 setup_python.py

# 4. Run the example
python3 run_python.py
```

## What the Example Does

The `test_controller.py` example demonstrates:

1. **Key Generation**: Generates a random Stark private key for testing
2. **Class Hash Retrieval**: Gets the latest controller class hash
3. **Owner Creation**: Creates an owner from the private key
4. **Controller Creation**: Creates a headless controller instance
5. **Information Retrieval**: Gets controller address, username, app ID, and chain ID
6. **Signup**: Attempts to sign up with the controller (may fail if not connected to proper backend)
7. **Transaction Creation**: Creates a transfer transaction call
8. **Transaction Execution**: Executes the transaction (may fail if account not deployed/funded)
9. **Simplified Transfer**: Tests the built-in transfer method

## API Overview

The Python bindings provide access to the following main classes:

### Controller
- `Controller.new_headless(app_id, username, class_hash, rpc_url, owner, chain_id)` - Create headless controller
- `Controller.new(app_id, username, class_hash, rpc_url, owner, address, chain_id)` - Create full controller
- `Controller.from_storage(app_id)` - Load controller from storage
- `controller.address()` - Get controller address
- `controller.username()` - Get username
- `controller.app_id()` - Get app ID
- `controller.chain_id()` - Get chain ID
- `controller.signup(signer_type, session_expiration, cartridge_api_url)` - Sign up
- `controller.execute(call_list)` - Execute transaction calls
- `controller.transfer(recipient, amount)` - Simple transfer
- `controller.disconnect()` - Disconnect and clear storage

### DiplomatOwner
- `DiplomatOwner.new_from_starknet_signer(private_key)` - Create owner from Starknet private key

### CONTROLLERS
- `CONTROLLERS.get_class_hash(version)` - Get controller class hash for version

### DiplomatCall & DiplomatCallList
- `DiplomatCall(contract_address, selector)` - Create a contract call
- `call.push_calldata_str(data)` - Add string calldata
- `DiplomatCallList()` - Create call list
- `call_list.add_call(call)` - Add call to list

### Enums
- `Version.LATEST` - Latest controller version
- `SignerType.Starknet` - Starknet signer type

## Error Handling

All operations that can fail return results that should be checked. The Python bindings will raise exceptions on errors, so use try-catch blocks:

```python
try:
    controller = Controller.new_headless(...)
    print("Controller created successfully")
except Exception as e:
    print(f"Failed to create controller: {e}")
```

## Troubleshooting

### Import Errors

If you get import errors:
1. Make sure the Rust library is built: `./scripts/build.sh`
2. Check that nanobind is installed: `pip install nanobind`
3. Verify the Python path includes the bindings directory
4. Ensure the dynamic library path is set correctly

### Runtime Errors

If you get runtime errors:
1. Check that you're connected to the correct RPC endpoint
2. Verify the private key format (should start with "0x")
3. Ensure the account has sufficient funds for transactions
4. Check that the Cartridge API URL is accessible (for signup)

### Platform-Specific Issues

**macOS**: Make sure `DYLD_LIBRARY_PATH` includes the library directory
**Linux**: Use `LD_LIBRARY_PATH` instead of `DYLD_LIBRARY_PATH`

## Development

To modify the example:
1. Edit `test_controller.py`
2. The bindings are auto-generated from the Rust code
3. If you modify the Rust API, rebuild with `./scripts/build.sh`

## Security Note

⚠️ **WARNING**: The example generates random private keys for testing purposes only. Never use these keys in production or with real funds!
