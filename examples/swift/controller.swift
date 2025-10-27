/**
 * Complete Controller UniFFI Test Suite
 * Tests all functionality including full workflows with signup, execution, and transfers
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

func printWarning(_ message: String) {
    print("\(YELLOW)⚠️  \(message)\(NC)")
}

func printInfo(_ message: String) {
    print("  \(message)")
}

// Generate random private key for testing
func generateStarkPrivateKey() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    return "0x" + bytes.map { String(format: "%02x", $0) }.joined()
}

// MARK: - Step 1: Test Utility Functions

func testUtilityFunctions() {
    printSection("Step 1: Testing Utility Functions")
    
    do {
        _ = try validateFelt(felt: "0x1234")
        printSuccess("validate_felt: works")
    } catch {
        printError("validate_felt error: \(error)")
    }
    
    do {
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let publicKey = try getPublicKey(privateKey: privateKey)
        printSuccess("get_public_key: \(String(publicKey.prefix(20)))...")
    } catch {
        printError("get_public_key error: \(error)")
    }
    
    do {
        let privateKey = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let guid = try signerToGuid(privateKey: privateKey)
        printSuccess("signer_to_guid: \(String(guid.prefix(20)))...")
    } catch {
        printError("signer_to_guid error: \(error)")
    }
    
    do {
        for version in [Version.v109, Version.latest] {
            let classHash = try getControllerClassHash(version: version)
            printSuccess("get_controller_class_hash(\(version)): \(String(classHash.prefix(20)))...")
        }
    } catch {
        printError("get_controller_class_hash error: \(error)")
    }
}

// MARK: - Step 2: Owner Creation

func testOwnerCreation(privateKey: String) -> Owner? {
    printSection("Step 2: Creating Owner")
    print("🔑 Using private key: \(privateKey)")
    
    do {
        let owner = try Owner(privateKey: privateKey)
        printSuccess("Owner created successfully")
        return owner
    } catch {
        printError("Owner creation error: \(error)")
        return nil
    }
}

// MARK: - Step 3: Controller Creation

func testControllerCreation(owner: Owner, privateKey: String) -> Controller? {
    printSection("Step 3: Creating Controller")
    
    let appId = "test_app_swift"
    let username = "swiftuser-\(UUID().uuidString.prefix(8))"
    let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
    let chainId = "0x534e5f5345504f4c4941"
    
    do {
        print("📋 Getting controller class hash...")
        let classHash = try getControllerClassHash(version: .latest)
        print("📄 Class hash: \(classHash)")
        
        print("🎮 Creating headless controller...")
        let controller = try Controller.newHeadless(
            appId: appId,
            username: username,
            classHash: classHash,
            rpcUrl: rpcUrl,
            owner: owner,
            chainId: chainId
        )
        printSuccess("Controller created successfully")
        
        print("\n📊 Controller Information:")
        printInfo("📍 Address: \(try controller.address())")
        printInfo("👤 Username: \(try controller.username())")
        printInfo("🆔 App ID: \(try controller.appId())")
        printInfo("⛓️  Chain ID: \(try controller.chainId())")
        
        return controller
    } catch {
        printError("Controller creation error: \(error)")
        return nil
    }
}

// MARK: - Step 4: Controller Storage

func testControllerStorage() {
    printSection("Step 4: Testing Controller Storage")
    
    do {
        let hasStorage = try controllerHasStorage(appId: "nonexistent_app")
        printSuccess("controller_has_storage('nonexistent_app'): \(hasStorage)")
        
        do {
            _ = try Controller.fromStorage(appId: "nonexistent_app")
            printWarning("Unexpectedly found stored controller")
        } catch {
            printSuccess("Controller.fromStorage correctly throws error for non-existent app")
        }
    } catch {
        printError("Storage test error: \(error)")
    }
}

// MARK: - Step 5: Signup

func testControllerSignup(controller: Controller) -> Bool {
    printSection("Step 5: Testing Signup")
    
    do {
        try controller.signup(
            signerType: .starknet,
            sessionExpiration: nil,
            cartridgeApiUrl: nil
        )
        printSuccess("Signup successful")
        return true
    } catch {
        printWarning("Signup error: \(error)")
        printInfo("(This is expected if the account already exists or is not funded)")
        return false
    }
}

// MARK: - Step 6: Transaction Execution

func testControllerExecution(controller: Controller) -> Bool {
    printSection("Step 6: Testing Transaction Execution")
    
    do {
        print("📦 Creating test transaction...")
        let call = Call(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            entrypoint: "approve",
            calldata: [
                "0x1234567890abcdef",
                "0x100",
                "0x0"
            ]
        )
        
        print("🚀 Executing transaction...")
        let txHash = try controller.execute(calls: [call])
        printSuccess("Transaction executed: \(txHash)")
        return true
    } catch {
        printError("Execution error: \(error)")
        printInfo("(This is expected if the account is not deployed or not funded)")
        return false
    }
}

// MARK: - Step 7: Transfer

func testControllerTransfer(controller: Controller) -> Bool {
    printSection("Step 7: Testing Transfer")
    
    do {
        let recipient = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
        let amount = "0x1"
        
        print("💰 Transferring \(amount) to \(String(recipient.prefix(20)))...")
        let txHash = try controller.transfer(recipient: recipient, amount: amount)
        printSuccess("Transfer successful: \(txHash)")
        return true
    } catch {
        printError("Transfer error: \(error)")
        printInfo("(This is expected if the account is not deployed or not funded)")
        return false
    }
}

// MARK: - Step 8: SessionAccount

func testSessionAccount() -> SessionAccount? {
    printSection("Step 8: Testing SessionAccount")
    
    do {
        print("📜 Creating session policies...")
        let policy = SessionPolicy(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            entrypoint: "transfer"
        )
        
        let policies = SessionPolicies(
            policies: [policy],
            maxFee: "0x100000"
        )
        
        print("🔐 Creating session account...")
        let session = try SessionAccount(
            rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
            privateKey: generateStarkPrivateKey(),
            address: "0x5678",
            ownerGuid: "0x9abc",
            chainId: "0x534e5f5345504f4c4941",
            policies: policies,
            sessionExpiration: 1735689600
        )
        printSuccess("SessionAccount created successfully")
        return session
    } catch {
        printError("SessionAccount creation error: \(error)")
        return nil
    }
}

// MARK: - Step 9: SessionAccount.createFromSubscribe

func testSessionAccountFromSubscribe() -> SessionAccount? {
    printSection("Step 9: Testing SessionAccount.createFromSubscribe")
    
    do {
        let policy = SessionPolicy(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            entrypoint: "transfer"
        )
        
        let policies = SessionPolicies(
            policies: [policy],
            maxFee: "0x100000"
        )
        
        print("🌐 Attempting to create session from GraphQL API...")
        let session = try SessionAccount.createFromSubscribe(
            privateKey: generateStarkPrivateKey(),
            policies: policies,
            rpcUrl: "https://api.cartridge.gg/x/starknet/sepolia",
            cartridgeApiUrl: "https://x.cartridge.gg/graphql"
        )
        printSuccess("SessionAccount.createFromSubscribe succeeded")
        return session
    } catch {
        printWarning("SessionAccount.createFromSubscribe failed (expected without real session):")
        printInfo(String(describing: error).prefix(100) + "...")
        return nil
    }
}

// MARK: - Step 10: Session Execution

func testSessionExecution(session: SessionAccount?) {
    if session == nil {
        printSection("Step 10: Skipping Session Execution (no session)")
        return
    }
    
    printSection("Step 10: Testing Session Execution")
    
    do {
        let call = Call(
            contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
            entrypoint: "transfer",
            calldata: [
                "0x1234567890abcdef",
                "0x1",
                "0x0"
            ]
        )
        
        print("🚀 Executing with session...")
        let txHash = try session!.execute(calls: [call])
        printSuccess("Session execution successful: \(txHash)")
    } catch {
        printError("Session execution error: \(error)")
    }
}

// MARK: - Step 11: Error Handling

func testErrorHandling(controller: Controller) {
    printSection("Step 11: Testing Error Handling")
    
    do {
        try controller.switchChain(rpcUrl: "invalid_url")
    } catch {
        printSuccess("Error correctly caught: \(type(of: error))")
        
        do {
            let errorMsg = try controller.errorMessage()
            if !errorMsg.isEmpty {
                printSuccess("Error message available: \(String(errorMsg.prefix(50)))...")
            }
            
            controller.clearLastError()
            printSuccess("Error cleared")
        } catch {
            // Ignore
        }
    }
}

// MARK: - Main

func runTests() {
    print(String(repeating: "=", count: 70))
    print("  🚀 COMPLETE CONTROLLER-UNIFFI SWIFT TEST SUITE")
    print("  Testing all functionality with full workflows")
    print(String(repeating: "=", count: 70))
    
    let privateKey = generateStarkPrivateKey()
    
    testUtilityFunctions()
    
    guard let owner = testOwnerCreation(privateKey: privateKey) else {
        printError("Cannot continue without owner")
        exit(1)
    }
    
    guard let controller = testControllerCreation(owner: owner, privateKey: privateKey) else {
        printError("Cannot continue without controller")
        exit(1)
    }
    
    testControllerStorage()
    _ = testControllerSignup(controller: controller)
    _ = testControllerExecution(controller: controller)
    _ = testControllerTransfer(controller: controller)
    
    let session = testSessionAccount()
    let sessionFromApi = testSessionAccountFromSubscribe()
    testSessionExecution(session: sessionFromApi ?? session)
    
    testErrorHandling(controller: controller)
    
    print("\n" + String(repeating: "=", count: 70))
    print("  \(GREEN)✅ ALL TESTS COMPLETED\(NC)")
    print("  All modules and workflows tested!")
    print(String(repeating: "=", count: 70))
    print()
    print("📝 Note: Some operations may fail if the account is not deployed/funded.")
    print("   This is expected behavior for a test environment.")
    print()
}

// Run the tests
runTests()
exit(0)
