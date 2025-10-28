/**
 * SessionAccount Example
 * Demonstrates how to create and use a session account with the Controller
 * This follows the same flow as the C example
 */

import Foundation

// ANSI color codes
let GREEN = "\u{001B}[0;32m"
let RED = "\u{001B}[0;31m"
let BLUE = "\u{001B}[0;34m"
let YELLOW = "\u{001B}[1;33m"
let NC = "\u{001B}[0m"

func printSection(_ title: String) {
    print("\n\(BLUE)=== \(title) ===\(NC)")
}

func printSuccess(_ message: String) {
    print("\(GREEN)✓ \(message)\(NC)")
}

func printError(_ message: String) {
    print("\(RED)❌ \(message)\(NC)")
}

func printInfo(_ message: String) {
    print("  \(message)")
}

// Configuration
let RPC_URL = "https://api.cartridge.gg/x/starknet/mainnet"
let CARTRIDGE_API_URL = "https://api.cartridge.gg"
let KEYCHAIN_URL = "https://x.cartridge.gg"

// Generate random private key for testing
func generateStarkPrivateKey() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    return "0x" + bytes.map { String(format: "%02x", $0) }.joined()
}

func sessionAccountExample() {
    print(String(repeating: "=", count: 70))
    print("  🔐 SESSION ACCOUNT EXAMPLE")
    print("  Create and use a session account with Controller")
    print(String(repeating: "=", count: 70))
    
    // Step 1: Generate private key
    printSection("Step 1: Generate Private Key")
    let privateKey = generateStarkPrivateKey()
    printInfo("🔑 Private key: \(privateKey)")
    printSuccess("Private key generated")
    
    // Step 2: Get public key
    printSection("Step 2: Get Public Key")
    var publicKey: String
    do {
        publicKey = try getPublicKey(privateKey: privateKey)
        printInfo("🔓 Public key: \(publicKey)")
        printSuccess("Public key derived")
    } catch {
        printError("Failed to get public key: \(error)")
        return
    }
    
    // Step 3: Build session policies
    printSection("Step 3: Build Session Policies")
    
    // ETH token contract address
    let ethContractAddress = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
    
    let transferPolicy = SessionPolicy(
        contractAddress: ethContractAddress,
        entrypoint: "transfer"
    )
    
    let approvePolicy = SessionPolicy(
        contractAddress: ethContractAddress,
        entrypoint: "approve"
    )
    
    let policies = SessionPolicies(
        policies: [transferPolicy, approvePolicy],
        maxFee: "0x100000000000000" // 0.0001 ETH in wei
    )
    
    printInfo("📜 Created policies for ETH contract:")
    printInfo("   - transfer")
    printInfo("   - approve")
    printSuccess("Session policies created")
    
    // Step 4: Create session URL
    printSection("Step 4: Create Session Link")
    
    // URL encode the policies
    let policiesJson = """
    [{"target":"\(ethContractAddress)","method":"transfer"},{"target":"\(ethContractAddress)","method":"approve"}]
    """
    let encodedPolicies = policiesJson.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let sessionUrl = """
    \(KEYCHAIN_URL)/session\
    ?public_key=\(publicKey)\
    &policies=\(encodedPolicies)\
    &rpc_url=\(RPC_URL)\
    &redirect_uri=https://docs.cartridge.gg/controller/overview\
    &redirect_query_name=startapp
    """
    
    print("\n" + String(repeating: "─", count: 70))
    print("\(YELLOW)📱 Please open a browser to this URL and create a session:\(NC)")
    print("\n\(sessionUrl)\n")
    print(String(repeating: "─", count: 70))
    
    print("\nPress ENTER to continue when the session is created...")
    _ = readLine()
    
    // Step 5: Create session account from subscribe
    printSection("Step 5: Create SessionAccount from API")
    
    var sessionAccount: SessionAccount?
    do {
        print("🌐 Connecting to Cartridge API...")
        sessionAccount = try SessionAccount.createFromSubscribe(
            privateKey: privateKey,
            policies: policies,
            rpcUrl: RPC_URL,
            cartridgeApiUrl: CARTRIDGE_API_URL
        )
        printSuccess("Session account created successfully!")
        printInfo("📊 Session connected and ready to use!")
        
    } catch {
        printError("Failed to create session account: \(error)")
        printInfo("This can happen if:")
        printInfo("  - The session was not created in the browser")
        printInfo("  - The public key doesn't match")
        printInfo("  - Network connectivity issues")
        return
    }
    
    // Step 6: Test session execution
    printSection("Step 6: Test Session Execution")
    
    guard let session = sessionAccount else {
        printError("No session account available")
        return
    }
    
    do {
        print("📦 Creating test transfer call...")
        let recipient = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let amount = "0x1" // 1 wei
        
        let call = Call(
            contractAddress: ethContractAddress,
            entrypoint: "transfer",
            calldata: [
                recipient,
                amount,
                "0x0" // high bits of u256
            ]
        )
        
        print("🚀 Executing transaction with session...")
        let txHash = try session.execute(calls: [call])
        printSuccess("Transaction executed successfully!")
        printInfo("📝 Transaction hash: \(txHash)")
        printInfo("🔍 View on Starkscan: https://sepolia.starkscan.co/tx/\(txHash)")
        
    } catch {
        printError("Transaction execution failed: \(error)")
        printInfo("This is expected if:")
        printInfo("  - The account has insufficient balance")
        printInfo("  - The session doesn't have permission")
        printInfo("  - The account is not deployed")
    }
    
    // Step 7: Note about session persistence
    printSection("Step 7: Session Persistence")
    
    print("💾 In a production app, you would:")
    printInfo("  - Store session credentials securely")
    printInfo("  - Check session expiration before use")
    printInfo("  - Refresh sessions when needed")
    printInfo("  - Handle session revocation gracefully")
    
    // Summary
    print("\n" + String(repeating: "=", count: 70))
    print("  \(GREEN)✅ SESSION ACCOUNT EXAMPLE COMPLETED\(NC)")
    print(String(repeating: "=", count: 70))
    print("\n📝 Summary:")
    print("   1. ✓ Generated private/public key pair")
    print("   2. ✓ Created session policies")
    print("   3. ✓ Generated session URL for browser")
    print("   4. ✓ Created session from API")
    print("   5. ✓ Tested transaction execution")
    print("\n💡 Next steps:")
    print("   - Store the session for reuse")
    print("   - Implement session refresh logic")
    print("   - Handle session expiration")
    print()
}

// Entry point
@main
struct SessionAccountExampleApp {
    static func main() {
        sessionAccountExample()
        exit(0)
    }
}

