//
//  ControllerManager.swift
//  Manages Controller state and operations
//

import Foundation
import Combine

@MainActor
class ControllerManager: ObservableObject {
    @Published var controller: Controller?
    @Published var sessionAccount: SessionAccount?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var controllerAddress: String?
    @Published var username: String?
    
    // Configuration
    let appId = "com.cartridge.demo"
    let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
    let cartridgeApiUrl = "https://api.cartridge.gg"
    let chainId = "0x534e5f5345504f4c4941" // SN_SEPOLIA
    
    // Generate or load private key (in production, use secure storage)
    private var privateKey: String {
        get {
            if let key = UserDefaults.standard.string(forKey: "privateKey") {
                return key
            }
            let newKey = generatePrivateKey()
            UserDefaults.standard.set(newKey, forKey: "privateKey")
            return newKey
        }
    }
    
    init() {
        loadController()
    }
    
    // MARK: - Controller Operations
    
    func createController(username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let owner = try Owner(privateKey: privateKey)
            let classHash = try getControllerClassHash(version: .latest)
            
            controller = try Controller.newHeadless(
                appId: appId,
                username: username,
                classHash: classHash,
                rpcUrl: rpcUrl,
                owner: owner,
                chainId: chainId
            )
            
            self.username = username
            self.controllerAddress = try controller?.address()
            
            successMessage = "Controller created successfully!"
            saveController()
        } catch {
            errorMessage = "Failed to create controller: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadController() {
        do {
            if try controllerHasStorage(appId: appId) {
                controller = try Controller.fromStorage(appId: appId)
                username = try controller?.username()
                controllerAddress = try controller?.address()
            }
        } catch {
            print("No stored controller found")
        }
    }
    
    func signup() async {
        guard let controller = controller else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try controller.signup(
                signerType: .starknet,
                sessionExpiration: nil,
                cartridgeApiUrl: nil
            )
            successMessage = "Account deployed successfully!"
        } catch {
            errorMessage = "Signup failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Operations
    
    func executeTransaction(contractAddress: String, entrypoint: String, calldata: [String]) async -> String? {
        guard let controller = controller else {
            errorMessage = "No controller available"
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let call = Call(
                contractAddress: contractAddress,
                entrypoint: entrypoint,
                calldata: calldata
            )
            
            let txHash = try controller.execute(calls: [call])
            successMessage = "Transaction sent!"
            isLoading = false
            return txHash
        } catch {
            errorMessage = "Transaction failed: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    func transfer(recipient: String, amount: String) async -> String? {
        guard let controller = controller else {
            errorMessage = "No controller available"
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let txHash = try controller.transfer(recipient: recipient, amount: amount)
            successMessage = "Transfer sent!"
            isLoading = false
            return txHash
        } catch {
            errorMessage = "Transfer failed: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Session Operations
    
    func createSession() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create session policies
            let ethContract = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
            
            let policies = SessionPolicies(
                policies: [
                    SessionPolicy(contractAddress: ethContract, entrypoint: "transfer"),
                    SessionPolicy(contractAddress: ethContract, entrypoint: "approve")
                ],
                maxFee: "0x100000000000000"
            )
            
            sessionAccount = try SessionAccount.createFromSubscribe(
                privateKey: privateKey,
                policies: policies,
                rpcUrl: rpcUrl,
                cartridgeApiUrl: cartridgeApiUrl
            )
            
            successMessage = "Session created successfully!"
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func executeWithSession(contractAddress: String, entrypoint: String, calldata: [String]) async -> String? {
        guard let session = sessionAccount else {
            errorMessage = "No session available"
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let call = Call(
                contractAddress: contractAddress,
                entrypoint: entrypoint,
                calldata: calldata
            )
            
            let txHash = try session.execute(calls: [call])
            successMessage = "Transaction sent with session!"
            isLoading = false
            return txHash
        } catch {
            errorMessage = "Session transaction failed: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    // MARK: - Utility
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    private func saveController() {
        // Controller automatically saves to storage
    }
    
    private func generatePrivateKey() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return "0x" + bytes.map { String(format: "%02x", $0) }.joined()
    }
}


