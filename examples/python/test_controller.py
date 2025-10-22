#!/usr/bin/env python3
"""
Python example for Controller SDK using UniFFI bindings.

This example demonstrates:
1. Generating or using a Stark key pair
2. Creating a Controller instance
3. Getting controller information
4. Signing up with the controller
5. Executing a transaction (transfer)

Requirements:
- Build the UniFFI bindings first: ./scripts/build_python.sh
- Install required Python packages: pip install secrets
"""

import secrets
import sys
import uuid
import os
import shutil
from pathlib import Path

# Setup paths
repo_root = Path(__file__).parent.parent.parent
bindings_path = repo_root / "bindings" / "python"
lib_source = repo_root / "target" / "release" / "libcontroller_uniffi.dylib"
lib_dest = bindings_path / "libcontroller_uniffi.dylib"

# Copy library to bindings directory if it doesn't exist or is outdated
if lib_source.exists():
    if not lib_dest.exists() or lib_source.stat().st_mtime > lib_dest.stat().st_mtime:
        print(f"Copying library from {lib_source} to {lib_dest}...")
        shutil.copy2(lib_source, lib_dest)
        print("✓ Library copied")
else:
    print(f"❌ Library not found at {lib_source}")
    print("Please build the bindings first: ./scripts/build_python.sh")
    sys.exit(1)

# Add the bindings directory to the path
sys.path.insert(0, str(bindings_path))

try:
    from controller_uniffi import (
        Owner,
        Controller,
        Call,
        SignerType,
        Version,
        ControllerError,
        get_controller_class_hash,
    )
except ImportError as e:
    print(f"❌ Failed to import controller_uniffi module: {e}")
    print("Make sure to build the UniFFI bindings first: ./scripts/build_python.sh")
    sys.exit(1)


def generate_stark_private_key():
    """Generate a random Stark private key for testing."""
    # Generate 32 random bytes and convert to hex
    private_key_bytes = secrets.randbits(252).to_bytes(32, byteorder='big')
    private_key_hex = "0x" + private_key_bytes.hex()
    return private_key_hex


def main():
    print("🚀 Controller Python Example (UniFFI)")
    print("=" * 50)

    # Constants
    ETH_CONTRACT_ADDRESS = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    STRK_CONTRACT_ADDRESS = "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d"

    # Configuration
    cartridge_api_url = "https://api.cartridge.gg"
    app_id = "test_app_python"
    username = f"pythonuser-{uuid.uuid4().hex[:8]}"
    rpc_url = f"{cartridge_api_url}/x/starknet/sepolia"
    chain_id = "0x534e5f5345504f4c4941"  # SN_SEPOLIA
    # chain_id = "0x534e5f4d41494e"  # SN_MAIN

    # Generate or use a test private key
    # WARNING: This is for testing only - never use in production!
    private_key = generate_stark_private_key()
    print(f"🔑 Generated private key: {private_key}")

    try:
        # Step 1: Get the class hash
        print("\n📋 Step 1: Getting class hash...")
        class_hash = get_controller_class_hash(Version.LATEST)
        print(f"📄 Class hash: {class_hash}")

        # Step 2: Create owner from private key
        print("\n👤 Step 2: Creating owner from private key...")
        owner = Owner(private_key)
        print("✅ Owner created successfully")

        # Step 3: Create controller (headless)
        print("\n🎮 Step 3: Creating controller...")
        controller = Controller.new_headless(
            app_id=app_id,
            username=username,
            class_hash=class_hash,
            rpc_url=rpc_url,
            owner=owner,
            chain_id=chain_id
        )
        print("✅ Controller created successfully")

        # Step 4: Get controller information
        print("\n📊 Step 4: Getting controller information...")

        controller_address = controller.address()
        print(f"📍 Controller address: {controller_address}")

        controller_username = controller.username()
        print(f"👤 Controller username: {controller_username}")

        controller_app_id = controller.app_id()
        print(f"🆔 Controller app_id: {controller_app_id}")

        controller_chain_id = controller.chain_id()
        print(f"⛓️  Controller chain_id: {controller_chain_id}")

        try:
            # Step 5: Signup with controller
            print("\n✍️  Step 5: Signing up...")
            controller.signup(
                signer_type=SignerType.STARKNET,
                session_expiration=19999999999999,
                cartridge_api_url=cartridge_api_url
            )
            print("✅ Signup successful")
        except ControllerError as e:
            error_message = controller.error_message()
            print(f"❌ Error during signup: {error_message}")
            print(f"   (This is expected if the account doesn't exist yet)")

        # Step 6: Create and execute a transaction
        print("\n💸 Step 6: Creating transaction...")

        # Create a transfer call using the Call record
        call = Call(
            contract_address=ETH_CONTRACT_ADDRESS,
            entrypoint="transfer",
            calldata=[
                controller_address,  # recipient (send to self)
                "0x0",  # amount_low = 0
                "0x0",  # amount_high = 0
            ]
        )

        print("📦 Transaction created")

        # Execute the transaction
        try:
            print("\n🚀 Step 7: Executing transaction...")
            tx_hash = controller.execute([call])
            print(f"✅ Transaction executed successfully!")
            print(f"📍 Transaction hash: {tx_hash}")
        except ControllerError as e:
            error_message = controller.error_message()
            print(f"❌ Error during execution: {error_message}")
            print(f"   (This is expected if the account is not deployed yet)")

        try:
            # Step 8: Try the simplified transfer method
            print("\n💰 Step 8: Testing simplified transfer...")

            recipient = controller_address  # Send to self
            amount = "0x0"  # 0 wei
            tx_hash = controller.transfer(recipient, amount)
            print(f"✅ Transfer successful!")
            print(f"📍 Transaction hash: {tx_hash}")
        except ControllerError as e:
            error_message = controller.error_message()
            print(f"❌ Error during transfer: {error_message}")
            print(f"   (This is expected if the account is not deployed yet)")

        print("\n🎉 Example completed successfully!")
        print("\nNote: Some operations may fail if the account is not deployed.")
        print("To deploy, you would need to:")
        print("  1. Complete the signup process")
        print("  2. Fund the account")
        print("  3. Then execute transactions")

    except ControllerError as e:
        print(f"❌ Controller Error: {e}")
        return 1
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
