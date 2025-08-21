#!/usr/bin/env python3
"""
Python example for Controller SDK using nanobind bindings.

This example demonstrates:
1. Generating or using a Stark key pair
2. Creating a Controller instance
3. Getting controller information
4. Signing up with the controller
5. Executing a transaction (transfer)

Requirements:
- Build the nanobind bindings first: run the build script
- Install required Python packages: pip install secrets
"""

import secrets
import sys
import os

# Add the bindings path to Python path
# Assuming the compiled nanobind module is available
try:
    import controller_c
except ImportError as e:
    print(f"❌ Failed to import controller_c module: {e}")
    print("Make sure to build the nanobind bindings first!")
    sys.exit(1)


def generate_stark_private_key():
    """Generate a random Stark private key for testing."""
    # Generate 32 random bytes and convert to hex
    private_key_bytes = secrets.randbits(252).to_bytes(32, byteorder='big')
    private_key_hex = "0x" + private_key_bytes.hex()
    return private_key_hex


def main():
    print("🚀 Controller Python Example")
    print("=" * 50)
    
    # Constants
    ETH_CONTRACT_ADDRESS = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    
    # Configuration
    cartridge_api_url = "https://api.cartridge.gg"
    app_id = "test_app_python"
    username = "pythonuser5"
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
        class_hash = controller_c.CONTROLLERS.get_class_hash(controller_c.Version.LATEST)
        print(f"📄 Class hash: {class_hash}")
        
        # Step 2: Create owner from private key
        print("\n👤 Step 2: Creating owner from private key...")
        owner = controller_c.DiplomatOwner.new_from_starknet_signer(private_key)
        print("✅ Owner created successfully")
        
        # Step 3: Create controller (headless)
        print("\n🎮 Step 3: Creating controller...")
        controller = controller_c.Controller.new_headless(
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
        
        # Step 5: Signup with controller
        print("\n✍️  Step 5: Signing up...")
        controller.signup(
            signer_type=controller_c.SignerType.Starknet,
            session_expiration=19999999999999,
            cartridge_api_url=cartridge_api_url
        )
        print("✅ Signup successful")

        # Step 6: Create and execute a transaction
        print("\n💸 Step 6: Creating transaction...")
        
        # Create call list
        call_list = controller_c.DiplomatCallList.new()
        
        # Create a transfer call
        # Using the transfer selector for ERC20 transfer
        transfer_selector = "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e"
        call = controller_c.DiplomatCall.new(ETH_CONTRACT_ADDRESS, transfer_selector)
        
        # Add calldata (recipient, amount_low, amount_high)
        call.push_calldata_str(controller_address)  # Send to self
        call.push_calldata_str("0x0")  # amount_low = 0
        call.push_calldata_str("0x0")  # amount_high = 0
        
        # Add call to call list
        call_list.add_call(call)
        
        print("📦 Transaction created")
        
        # Execute the transaction
        print("\n🚀 Step 7: Executing transaction...")
        tx_hash = controller.execute(call_list)
        print(f"✅ Transaction executed successfully!")
        print(f"📍 Transaction hash: {tx_hash}")
        
        # Step 8: Try the simplified transfer method
        print("\n💰 Step 8: Testing simplified transfer...")

        recipient = controller_address  # Send to self
        amount = "0x1"  # 1 wei
        tx_hash = controller.transfer(recipient, amount)
        print(f"✅ Transfer successful!")
        print(f"📍 Transaction hash: {tx_hash}")
        
        print("\n🎉 Example completed successfully!")
        
    except Exception:
        error_message = controller_c.ControllerError.get_last_error_message()
        print(f"❌ Error during execution: {error_message}")
        return 1
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
