import Foundation
import ControllerSDK

// Example usage of the Controller SDK Swift bindings
func main() {
    print("Controller SDK Swift Example")
    print("============================\n")

    do {
        // Example 1: Create a new Controller
        print("Creating a new Controller...")

        let appId = "myapp"
        let username = "testuser"
        let classHash = "0x1234567890abcdef"
        let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
        let chainId = "0x534e5f474f45524c49" // SN_GOERLI

        // Create owner with Starknet signer
        let owner = Owner(type: .starknet, privateKey: "0xYourPrivateKeyHere")

        // Initialize Controller
        let controller = try Controller(
            appId: appId,
            username: username,
            classHash: classHash,
            rpcUrl: rpcUrl,
            owner: owner,
            address: "0x0", // Will be computed
            chainId: chainId
        )

        print("Controller created successfully!")
        print("Address: \(try controller.address)")
        print("Username: \(try controller.username)")
        print("App ID: \(try controller.appId)")
        print("Chain ID: \(try controller.chainId)")

        // Example 2: Sign up with a signer
        print("\nSigning up...")
        try controller.signup(
            signerType: .starknet,
            sessionExpiration: nil,
            cartridgeApiUrl: nil
        )
        print("Signup successful!")

        // Example 3: Execute a transaction
        print("\nExecuting a transaction...")

        let call = Call(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            selector: "transfer",
            calldata: [
                "0x1234567890abcdef", // recipient
                "1000000000000000",   // amount (low)
                "0"                   // amount (high)
            ]
        )

        let txResult = try controller.execute(calls: [call])
        print("Transaction result: \(txResult)")

        // Example 4: Load from storage
        print("\nLoading Controller from storage...")
        let loadedController = try Controller.fromStorage(appId: appId)
        print("Loaded Controller address: \(try loadedController.address)")

        // Example 5: Disconnect
        print("\nDisconnecting...")
        try controller.disconnect()
        print("Disconnected successfully!")

    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

// Example with SessionAccount
func sessionAccountExample() {
    print("\n\nSession Account Example")
    print("======================\n")

    do {
        // Create a session account
        let signer = Signer(type: .starknet, privateKey: "0xSessionPrivateKey")

        let sessionAccount = try SessionAccount(
            rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
            signer: signer,
            address: "0xAccountAddress",
            username: "sessionuser",
            chainId: "0x534e5f474f45524c49",
            sessionAuthorization: "auth_data_here",
            sessionKeyPair: "session_key_pair"
        )

        print("Session Account created!")
        print("Address: \(try sessionAccount.address)")
        print("Username: \(try sessionAccount.username)")

        // Execute with session account
        let call = Call(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            selector: "approve",
            calldata: ["0xSpenderAddress", "1000000", "0"]
        )

        let result = try sessionAccount.execute(calls: [call])
        print("Session execution result: \(result)")

    } catch {
        print("Session Account Error: \(error.localizedDescription)")
    }
}

// Run the examples
main()
sessionAccountExample()