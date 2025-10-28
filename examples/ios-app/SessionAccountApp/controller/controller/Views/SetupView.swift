//
//  SetupView.swift
//  Session setup and policy configuration
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showAddPolicy = false
    
    var body: some View {
        NavigationView {
            List {
                // Key Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Private Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(sessionManager.privateKey)
                            .font(.system(.caption2, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        
                        Text("Public Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
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
                        if sessionManager.isWaitingForBrowser {
                            VStack(spacing: 12) {
                                HStack {
                                    ProgressView()
                                    Text("Waiting for browser authorization...")
                                        .font(.callout)
                                }
                                .padding()
                                
                                Button {
                                    Task {
                                        await sessionManager.createSessionFromAPI()
                                    }
                                } label: {
                                    if sessionManager.isLoading {
                                        ProgressView()
                                    } else {
                                        Label("Subscribe & Create Session", systemImage: "arrow.down.circle")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(sessionManager.isLoading)
                            }
                        } else {
                            Button {
                                sessionManager.openSessionInBrowser()
                            } label: {
                                if sessionManager.isOpeningBrowser {
                                    HStack {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Opening Browser...")
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    Label("Open Browser to Authorize", systemImage: "safari")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(sessionManager.policies.filter { $0.enabled }.isEmpty || sessionManager.isOpeningBrowser)
                        }
                    } else {
                        Label("Session Active", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                        
                        Button(role: .destructive) {
                            sessionManager.reset()
                        } label: {
                            Label("Reset Session", systemImage: "trash")
                        }
                    }
                } footer: {
                    if sessionManager.isWaitingForBrowser {
                        Text("Complete authorization in browser, then return here. The session will be created automatically when you return!")
                    } else {
                        Text("1. Open browser to authorize the session\n2. Complete authorization in Keychain\n3. App will automatically create session when you return")
                    }
                }
            }
            .navigationTitle("Setup Session")
            .sheet(isPresented: $showAddPolicy) {
                AddPolicySheet()
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

