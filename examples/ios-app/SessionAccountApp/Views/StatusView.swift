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
                        if sessionManager.sessionAccount != nil {
                            Label("Active", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Label("No Session", systemImage: "xmark.circle")
                                .foregroundColor(.gray)
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
                            if let url = URL(string: "https://sepolia.voyager.online/tx/\(txHash)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("View on Voyager", systemImage: "safari")
                        }
                    } header: {
                        Text("Last Transaction")
                    }
                }
                
                // URLs
                Section {
                    if sessionManager.sessionAccount == nil {
                        Button {
                            Task {
                                await sessionManager.copySessionURLToClipboard()
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

