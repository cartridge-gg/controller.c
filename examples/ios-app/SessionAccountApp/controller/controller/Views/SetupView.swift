//
//  SetupView.swift
//  Session setup and policy configuration
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showAddPolicy = false
    @State private var showPrivateKey = false
    
    var body: some View {
        NavigationView {
            List {
                // Header Description
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Register a new session account with your Cartridge Controller")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }
                
                // Key Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Private Key")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if showPrivateKey {
                                    Text(sessionManager.privateKey)
                                        .font(.system(.caption2, design: .monospaced))
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                } else {
                                    Text(String(repeating: "•", count: 64))
                                        .font(.system(.caption2, design: .monospaced))
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                showPrivateKey.toggle()
                            } label: {
                                Image(systemName: showPrivateKey ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        Text("Public Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(sessionManager.publicKey)
                            .font(.system(.caption2, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    
                    Button {
                        sessionManager.generateNewKey()
                    } label: {
                        Label("Generate New Key", systemImage: "arrow.clockwise")
                    }
                } header: {
                    Text("Keys")
                }
                
                // Policies Section
                Section {
                    ForEach(Array(sessionManager.policies.enumerated()), id: \.element.id) { index, policy in
                        PolicyRow(policy: policy, index: index)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { sessionManager.removePolicy(at: $0) }
                    }
                    
                    Button {
                        showAddPolicy = true
                    } label: {
                        Label("Add Policy", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Policies")
                } footer: {
                    Text("Select which contracts and methods your session can call")
                }
                
                // Actions Section
                Section {
                    if sessionManager.sessionAccount == nil {
                        Button {
                            sessionManager.openSessionInWebView()
                        } label: {
                            if sessionManager.isLoading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                    Text("Waiting for Authorization...")
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 8)
                            } else {
                                HStack {
                                    Spacer()
                                    Image(systemName: "key.fill")
                                    Text("Register Session")
                                    Spacer()
                                }
                                .font(.headline)
                                .padding(.vertical, 12)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(sessionManager.policies.filter { $0.enabled }.isEmpty || sessionManager.isLoading)
                    } else {
                        // Session Active Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Session Active")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    
                                    if let username = sessionManager.sessionUsername {
                                        Text("Logged in as \(username)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            Button(role: .destructive) {
                                sessionManager.reset()
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "trash")
                                    Text("Reset Session")
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                    }
                } footer: {
                    if sessionManager.sessionAccount == nil {
                        Text("Register the session with your Cartridge account. The session will be created automatically after you complete the authorization.")
                    } else {
                        Text("Your session is active. Go to the Execute tab to send transactions.")
                    }
                }
            }
            .navigationTitle("Setup Session")
            .sheet(isPresented: $showAddPolicy) {
                AddPolicySheet()
            }
            .fullScreenCover(isPresented: $sessionManager.showWebView, onDismiss: {
                // Clean up if dismissed without completing
                if sessionManager.sessionAccount == nil {
                    sessionManager.cancelSubscription()
                }
            }) {
                if let url = URL(string: sessionManager.generateSessionURL()) {
                    InAppSafariView(
                        url: url,
                        onComplete: {
                            // User completed authorization, now create session
                            sessionManager.onWebViewComplete()
                        },
                        onError: { error in
                            sessionManager.errorMessage = error
                            sessionManager.showWebView = false
                        }
                    )
                }
            }
        }
    }
}

struct PolicyRow: View {
    @EnvironmentObject var sessionManager: SessionManager
    let policy: PolicyItem
    let index: Int
    
    var body: some View {
        HStack {
            Button {
                sessionManager.togglePolicy(at: index)
            } label: {
                Image(systemName: policy.enabled ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(policy.enabled ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
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
    }
}

struct AddPolicySheet: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var contractAddress = ""
    @State private var entrypoint = ""
    @State private var selectedContract = 0
    @State private var selectedMethod = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Contract", selection: $selectedContract) {
                        ForEach(0..<sessionManager.commonContracts.count, id: \.self) { index in
                            Text(sessionManager.commonContracts[index].0)
                        }
                        Text("Custom").tag(sessionManager.commonContracts.count)
                    }
                    .onChange(of: selectedContract) { oldValue, newValue in
                        if newValue < sessionManager.commonContracts.count {
                            contractAddress = sessionManager.commonContracts[newValue].1
                        } else {
                            contractAddress = ""
                        }
                    }
                    
                    if selectedContract == sessionManager.commonContracts.count {
                        TextField("Contract Address", text: $contractAddress)
                            .font(.system(.body, design: .monospaced))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        Text(contractAddress)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Contract")
                }
                
                Section {
                    Picker("Method", selection: $selectedMethod) {
                        ForEach(0..<sessionManager.commonMethods.count, id: \.self) { index in
                            Text(sessionManager.commonMethods[index])
                        }
                        Text("Custom").tag(sessionManager.commonMethods.count)
                    }
                    .onChange(of: selectedMethod) { oldValue, newValue in
                        if newValue < sessionManager.commonMethods.count {
                            entrypoint = sessionManager.commonMethods[newValue]
                        } else {
                            entrypoint = ""
                        }
                    }
                    
                    if selectedMethod == sessionManager.commonMethods.count {
                        TextField("Method Name", text: $entrypoint)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Method")
                }
                
                Section {
                    Button {
                        sessionManager.addPolicy(
                            contractAddress: contractAddress,
                            entrypoint: entrypoint
                        )
                        dismiss()
                    } label: {
                        Text("Add Policy")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(contractAddress.isEmpty || entrypoint.isEmpty)
                }
            }
            .navigationTitle("Add Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !sessionManager.commonContracts.isEmpty {
                    contractAddress = sessionManager.commonContracts[0].1
                }
                if !sessionManager.commonMethods.isEmpty {
                    entrypoint = sessionManager.commonMethods[0]
                }
            }
        }
    }
}

#Preview {
    SetupView()
        .environmentObject(SessionManager())
}

