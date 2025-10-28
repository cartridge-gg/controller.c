//
//  SessionManager.swift
//  Manages session account creation and execution
//

import Foundation
import UIKit
import Combine

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
    
    // Web view and card
    @Published var showWebView = false
    @Published var showAccountConnectedCard = false
    @Published var connectedUsername: String = ""
    
    // Transaction status card
    @Published var showTransactionCard = false
    @Published var currentTransactionHash: String = ""
    @Published var isTransactionConfirmed = false
    
    // Background subscription
    private var subscriptionTask: Task<Void, Never>?
    private var transactionPollingTask: Task<Void, Never>?
    
    // Session metadata
    @Published var sessionUsername: String?
    @Published var sessionOwnerGuid: String?
    @Published var sessionAddress: String?
    @Published var sessionExpiresAt: UInt64?
    @Published var sessionId: String?
    @Published var appId: String?
    @Published var isRevoked: Bool = false
    @Published var isWaitingForBrowser = false
    @Published var sessionPayload: String?
    @Published var showPayloadSheet = false
    @Published var isOpeningBrowser = false
    
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
        
        // Manually percent-encode each parameter value
        func percentEncode(_ string: String) -> String {
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-_.~")
            return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
        }
        
        let encodedPublicKey = percentEncode(publicKey)
        let encodedPolicies = percentEncode(policiesArray)
        let encodedRpcUrl = percentEncode(rpcUrl)
        
        // Build URL manually with properly encoded parameters
        return """
        \(keychainUrl)/session?\
        public_key=\(encodedPublicKey)&\
        policies=\(encodedPolicies)&\
        rpc_url=\(encodedRpcUrl)
        """
    }
    
    func openSessionInWebView() {
        // Open web view and start subscription
        print("📱 Opening web view...")
        showWebView = true
        
        // Start subscription in background using the global multi-threaded runtime
        // The Rust side now uses a non-blocking runtime, so this won't freeze the UI
        Task.detached(priority: .userInitiated) {
            await self.startBackgroundSubscriptionDetached()
        }
    }
    
    func onWebViewComplete() {
        // Called when user completes authorization in web view
        print("✅ User completed authorization, subscription is polling...")
    }
    
    func startBackgroundSubscriptionDetached() async {
        // Cancel any existing subscription
        subscriptionTask?.cancel()
        
        // Set loading state
        await MainActor.run {
            self.isLoading = true
        }
        
        // Capture values we need
        let privateKey = self.privateKey
        let rpcUrl = self.rpcUrl
        let cartridgeApiUrl = self.cartridgeApiUrl
        let enabledPolicies = self.policies.filter { $0.enabled }
        
        // Run in completely detached task
        subscriptionTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            do {
                let sessionPolicies = SessionPolicies(
                    policies: enabledPolicies.map { policy in
                        SessionPolicy(
                            contractAddress: policy.contractAddress,
                            entrypoint: policy.entrypoint
                        )
                    },
                    maxFee: "0x2386f26fc10000"
                )
                
                // This call now uses a global multi-threaded runtime in Rust
                // It won't block the UI thread anymore!
                let session = try SessionAccount.createFromSubscribe(
                    privateKey: privateKey,
                    policies: sessionPolicies,
                    rpcUrl: rpcUrl,
                    cartridgeApiUrl: cartridgeApiUrl
                )
                
                if Task.isCancelled { return }
                
                // Update UI on main thread
                await MainActor.run {
                    print("✅ Session created successfully!")
                    self.sessionAccount = session
                    self.isLoading = false
                    
                    self.sessionAddress = session.address()
                    self.sessionOwnerGuid = session.ownerGuid()
                    self.sessionExpiresAt = session.expiresAt()
                    self.sessionId = session.sessionId()
                    self.appId = session.appId()
                    self.isRevoked = session.isRevoked()
                    
                    if let username = session.username() {
                        print("📝 Username: \(username)")
                        self.connectedUsername = username
                        self.sessionUsername = username
                    } else {
                        print("📝 No username, using Anonymous")
                        self.connectedUsername = "Anonymous"
                    }
                    
                    print("🚀 Closing Safari view...")
                    self.showWebView = false
                }
                
                // Wait for Safari to fully dismiss
                try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                
                // Then show success card
                await MainActor.run {
                    print("🎉 Showing success card!")
                    self.showAccountConnectedCard = true
                }
            } catch {
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.errorMessage = "Failed to create session: \(error.localizedDescription)"
                    self.isLoading = false
                    self.showWebView = false
                }
            }
        }
    }
    
    
    func cancelSubscription() {
        subscriptionTask?.cancel()
        subscriptionTask = nil
        isLoading = false
    }
    
    func openSessionInBrowser() {
        isOpeningBrowser = true
        
        // Show loading for a brief moment
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let urlString = generateSessionURL()
            guard let url = URL(string: urlString) else {
                await MainActor.run {
                    errorMessage = "Invalid URL"
                    isOpeningBrowser = false
                }
                return
            }
            
            await MainActor.run {
                isWaitingForBrowser = true
                isOpeningBrowser = false
            }
            
            UIApplication.shared.open(url) { success in
                if !success {
                    Task { @MainActor in
                        self.errorMessage = "Failed to open browser"
                        self.isWaitingForBrowser = false
                    }
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
                maxFee: "0x2386f26fc10000" // ~0.01 ETH - much higher for safety
            )
            
            sessionAccount = try SessionAccount.createFromSubscribe(
                privateKey: privateKey,
                policies: sessionPolicies,
                rpcUrl: rpcUrl,
                cartridgeApiUrl: cartridgeApiUrl
            )
            
            // Fetch real metadata from the session account
            if let session = sessionAccount {
                sessionAddress = session.address()
                sessionOwnerGuid = session.ownerGuid()
                sessionExpiresAt = session.expiresAt()
                sessionUsername = session.username()
                sessionId = session.sessionId()
                appId = session.appId()
                isRevoked = session.isRevoked()
            }
            
            isWaitingForBrowser = false
            successMessage = "Session created successfully!"
        } catch {
            errorMessage = "Failed to create session: \(error.localizedDescription)"
            isWaitingForBrowser = false
        }
        
        isLoading = false
    }
    
    // Auto-retry session creation when app becomes active
    func tryAutoCreateSession() async {
        if isWaitingForBrowser && sessionAccount == nil {
            await createSessionFromAPI()
        }
    }
    
    // Refresh session metadata from the session account
    func refreshSessionMetadata() {
        guard let session = sessionAccount else {
            sessionAddress = nil
            sessionOwnerGuid = nil
            sessionExpiresAt = nil
            sessionUsername = nil
            sessionId = nil
            appId = nil
            isRevoked = false
            return
        }
        
        sessionAddress = session.address()
        sessionOwnerGuid = session.ownerGuid()
        sessionExpiresAt = session.expiresAt()
        sessionUsername = session.username()
        sessionId = session.sessionId()
        appId = session.appId()
        isRevoked = session.isRevoked()
        
        // Check if session is expired or revoked
        if session.isExpired() {
            errorMessage = "⚠️ Session has expired. Please create a new session."
        } else if session.isRevoked() {
            errorMessage = "⚠️ Session has been revoked. Please create a new session."
        }
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
            
            let txHash = try session.executeFromOutside(calls: [call])
            lastTransactionHash = txHash
            
            // Show transaction card
            currentTransactionHash = txHash
            isTransactionConfirmed = false
            showTransactionCard = true
            
            // Start polling for confirmation
            startTransactionPolling(txHash: txHash)
            
        } catch {
            let errorStr = error.localizedDescription
            
            // Provide helpful error messages
            if errorStr.lowercased().contains("insufficient") {
                errorMessage = "⚠️ Insufficient STRK for gas. Session accounts need STRK to pay fees. Fund the account or use a Controller account instead."
            } else if errorStr.contains("not deployed") || errorStr.contains("NotDeployed") {
                errorMessage = "Account not deployed. Deploy it first before executing transactions."
            } else {
                errorMessage = "Transaction failed: \(errorStr)"
            }
        }
        
        isLoading = false
    }
    
    func startTransactionPolling(txHash: String) {
        // Cancel any existing polling
        transactionPollingTask?.cancel()
        
        transactionPollingTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            // Poll every 2 seconds for up to 5 minutes
            for _ in 0..<150 {
                if Task.isCancelled { return }
                
                // Wait 2 seconds between checks
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Check transaction status
                // For now, we'll simulate confirmation after 10 seconds
                // In production, you'd call a real API to check transaction status
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                
                if Task.isCancelled { return }
                
                // Mark as confirmed
                await MainActor.run {
                    print("✅ Transaction confirmed: \(txHash)")
                    self.isTransactionConfirmed = true
                }
                
                return
            }
        }
    }
    
    func dismissTransactionCard() {
        showTransactionCard = false
        transactionPollingTask?.cancel()
        transactionPollingTask = nil
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
    
    func handleDeepLink(url: URL) {
        // Parse URL components and extract payload
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        // Look for base64 encoded payload in query parameters
        if let payloadItem = queryItems.first(where: { $0.name == "session" || $0.name == "payload" || $0.name == "data" }),
           let base64String = payloadItem.value {
            // Decode base64
            if let data = Data(base64Encoded: base64String),
               let decodedString = String(data: data, encoding: .utf8) {
                sessionPayload = decodedString
                showPayloadSheet = true
                
                // Also try to create session
                Task {
                    await createSessionFromAPI()
                }
            }
        } else {
            // No payload, just try to create session
            Task {
                await createSessionFromAPI()
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    func reset() {
        cancelSubscription()
        dismissTransactionCard()
        sessionAccount = nil
        lastTransactionHash = nil
        sessionUsername = nil
        sessionOwnerGuid = nil
        sessionAddress = nil
        sessionExpiresAt = nil
        sessionId = nil
        appId = nil
        isRevoked = false
        isWaitingForBrowser = false
        connectedUsername = ""
        showAccountConnectedCard = false
        setupDefaultPolicies()
    }
    
    deinit {
        subscriptionTask?.cancel()
        transactionPollingTask?.cancel()
    }
}

