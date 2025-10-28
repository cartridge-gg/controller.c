//
//  StatusView.swift
//  Session status and transaction history
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        NavigationView {
            List {
                // Session Status
                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        if let session = sessionManager.sessionAccount {
                            if session.isExpired() {
                                Label("Expired", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                            } else {
                                Label("Active", systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        } else if sessionManager.isWaitingForBrowser {
                            Label("Waiting...", systemImage: "hourglass")
                                .foregroundColor(.orange)
                        } else {
                            Label("No Session", systemImage: "xmark.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if sessionManager.sessionAccount != nil {
                        Button {
                            sessionManager.refreshSessionMetadata()
                        } label: {
                            Label("Refresh Metadata", systemImage: "arrow.clockwise")
                        }
                    }
                    
                    if let username = sessionManager.sessionUsername {
                        HStack {
                            Text("Username")
                            Spacer()
                            Text(username)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let ownerGuid = sessionManager.sessionOwnerGuid {
                        HStack {
                            Text("Owner GUID")
                            Spacer()
                            Text(ownerGuid.prefix(10) + "..." + ownerGuid.suffix(6))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let address = sessionManager.sessionAddress {
                        HStack {
                            Text("Session Address")
                            Spacer()
                            Text(address.prefix(10) + "..." + address.suffix(6))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let expiresAt = sessionManager.sessionExpiresAt {
                        HStack {
                            Text("Expires")
                            Spacer()
                            Text(Date(timeIntervalSince1970: TimeInterval(expiresAt)), style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Network")
                        Spacer()
                        Text("Sepolia")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Active Policies")
                        Spacer()
                        Text("\(sessionManager.policies.filter { $0.enabled }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    if sessionManager.isRevoked {
                        HStack {
                            Text("Revoked")
                            Spacer()
                            Label("Yes", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    
                    if let sessionId = sessionManager.sessionId {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Session ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(sessionId)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    if let appId = sessionManager.appId {
                        HStack {
                            Text("App ID")
                            Spacer()
                            Text(appId)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Session Info")
                }
                
                // Keys
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Public Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(sessionManager.publicKey)
                                .font(.system(.caption2, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Button {
                                UIPasteboard.general.string = sessionManager.publicKey
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                        }
                    }
                } header: {
                    Text("Keys")
                }
                
                // Active Policies
                if !sessionManager.policies.filter({ $0.enabled }).isEmpty {
                    Section {
                        ForEach(sessionManager.policies.filter { $0.enabled }) { policy in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(policy.entrypoint)
                                    .font(.headline)
                                
                                Text(policy.contractAddress)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                        }
                    } header: {
                        Text("Active Policies")
                    }
                }
                
                // Last Transaction
                if let txHash = sessionManager.lastTransactionHash {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Transaction Hash")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text(txHash)
                                    .font(.system(.caption2, design: .monospaced))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                
                                Button {
                                    UIPasteboard.general.string = txHash
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                        }
                        
                        Button {
                            if let url = URL(string: "https://sepolia.starkscan.co/tx/\(txHash)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("View on Starkscan", systemImage: "safari")
                        }
                    } header: {
                        Text("Last Transaction")
                    }
                }
                
                // URLs
                Section {
                    if sessionManager.sessionAccount == nil {
                        Button {
                            if let url = URL(string: sessionManager.generateSessionURL()) {
                                UIPasteboard.general.string = url.absoluteString
                                sessionManager.successMessage = "URL copied to clipboard"
                            }
                        } label: {
                            Label("Copy Session URL", systemImage: "link")
                        }
                    }
                    
                    Button {
                        if let url = URL(string: sessionManager.keychainUrl) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Open Keychain", systemImage: "key")
                    }
                } header: {
                    Text("Links")
                }
                
                // Configuration
                Section {
                    InfoRow(label: "RPC URL", value: sessionManager.rpcUrl)
                    InfoRow(label: "API URL", value: sessionManager.cartridgeApiUrl)
                    InfoRow(label: "Keychain URL", value: sessionManager.keychainUrl)
                } header: {
                    Text("Configuration")
                }
            }
            .navigationTitle("Status")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    StatusView()
        .environmentObject(SessionManager())
}

