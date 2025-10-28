//
//  SessionManager.swift
//  Manages session account creation and execution
//

import Foundation
import UIKit

struct PolicyItem: Identifiable, Codable {
    let id = UUID()
    var contractAddress: String
    var entrypoint: String
    var enabled: Bool = true
}

@MainActor
class SessionManager: ObservableObject {
    // Configuration
    let rpcUrl = "https://api.cartridge.gg/x/starknet/sepolia"
    let cartridgeApiUrl = "https://api.cartridge.gg"
    let keychainUrl = "https://x.cartridge.gg"
    
    // State
    @Published var sessionAccount: SessionAccount?
    @Published var privateKey: String = ""
    @Published var publicKey: String = ""
    @Published var policies: [PolicyItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var lastTransactionHash: String?
    
    // Common contracts
    let commonContracts = [
        ("ETH Token", "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"),
        ("STRK Token", "0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d"),
    ]
    
    let commonMethods = ["transfer", "approve", "transfer_from", "mint", "burn"]
    
    init() {
        loadOrGenerateKey()
        setupDefaultPolicies()
    }
    
    // MARK: - Key Management
    
    func loadOrGenerateKey() {
        if let saved = UserDefaults.standard.string(forKey: "session_private_key") {
            privateKey = saved
        } else {
            generateNewKey()
        }
        updatePublicKey()
    }
    
    func generateNewKey() {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        privateKey = "0x" + bytes.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(privateKey, forKey: "session_private_key")
        updatePublicKey()
    }
    
    func updatePublicKey() {
        do {
            publicKey = try getPublicKey(privateKey: privateKey)
        } catch {
            errorMessage = "Failed to derive public key: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Policy Management
    
    func setupDefaultPolicies() {
        policies = [
            PolicyItem(
                contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                entrypoint: "transfer"
            ),
            PolicyItem(
                contractAddress: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                entrypoint: "approve"
            )
        ]
    }
    
    func addPolicy(contractAddress: String, entrypoint: String) {
        let policy = PolicyItem(contractAddress: contractAddress, entrypoint: entrypoint)
        policies.append(policy)
    }
    
    func removePolicy(at index: Int) {
        policies.remove(at: index)
    }
    
    func togglePolicy(at index: Int) {
        policies[index].enabled.toggle()
    }
    
    // MARK: - Session Creation
    
    func generateSessionURL() -> String {
        let enabledPolicies = policies.filter { $0.enabled }
        
        let policiesJson = enabledPolicies.map { policy in
            """
            {"target":"\(policy.contractAddress)","method":"\(policy.entrypoint)"}
            """
        }.joined(separator: ",")
        
        let policiesArray = "[\(policiesJson)]"
        let encodedPolicies = policiesArray.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return """
        \(keychainUrl)/session\
        ?public_key=\(publicKey)\
        &policies=\(encodedPolicies)\
        &rpc_url=\(rpcUrl)\
        &redirect_uri=sessionaccount://callback\
        &redirect_query_name=session_created
        """
    }
    
    func openSessionInBrowser() {
        let urlString = generateSessionURL()
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        UIApplication.shared.open(url) { success in
            if !success {
                Task { @MainActor in
                    self.errorMessage = "Failed to open browser"
                }
            }
        }
    }
    
    func createSessionFromAPI() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let enabledPolicies = policies.filter { $0.enabled }
            
            let sessionPolicies = SessionPolicies(
                policies: enabledPolicies.map { policy in
                    SessionPolicy(
                        contractAddress: policy.contractAddress,
                        entrypoint: policy.entrypoint
                    )
                },
                maxFee: "0x100000000000000"
            )
            
            sessionAccount = try SessionAccount.createFromSubscribe(
                privateKey: privateKey,
                policies: sessionPolicies,
                rpcUrl: rpcUrl,
                cartridgeApiUrl: cartridgeApiUrl
            )
            
            successMessage = "Session created successfully!"
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Execution
    
    func executeTransaction(contractAddress: String, entrypoint: String, calldata: [String]) async {
        guard let session = sessionAccount else {
            errorMessage = "No session account available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        lastTransactionHash = nil
        
        do {
            let call = Call(
                contractAddress: contractAddress,
                entrypoint: entrypoint,
                calldata: calldata
            )
            
            let txHash = try session.execute_from_outside(calls: [call])
            lastTransactionHash = txHash
            successMessage = "Transaction sent!"
        } catch {
            errorMessage = "Transaction failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func executeTransfer(to recipient: String, amount: String) async {
        let ethContract = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
        await executeTransaction(
            contractAddress: ethContract,
            entrypoint: "transfer",
            calldata: [recipient, amount, "0x0"]
        )
    }
    
    func executeApprove(spender: String, amount: String) async {
        let ethContract = "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7"
        await executeTransaction(
            contractAddress: ethContract,
            entrypoint: "approve",
            calldata: [spender, amount, "0x0"]
        )
    }
    
    // MARK: - Utility
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    func reset() {
        sessionAccount = nil
        lastTransactionHash = nil
        setupDefaultPolicies()
    }
}


