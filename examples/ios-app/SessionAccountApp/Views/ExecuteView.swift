//
//  ExecuteView.swift
//  Execute transactions with the session
//

import SwiftUI

struct ExecuteView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showCustomCall = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if sessionManager.sessionAccount != nil {
                        // Quick Actions
                        quickActionsSection
                        
                        // Policy Actions
                        policyActionsSection
                        
                        // Custom Call
                        customCallSection
                    } else {
                        noSessionView
                    }
                }
                .padding()
            }
            .navigationTitle("Execute")
            .sheet(isPresented: $showCustomCall) {
                CustomCallSheet()
            }
        }
    }
    
    // MARK: - Components
    
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Transfer ETH",
                    icon: "arrow.right.circle",
                    color: .blue
                ) {
                    showCustomCall = true
                }
                
                QuickActionButton(
                    title: "Approve Spender",
                    icon: "checkmark.circle",
                    color: .green
                ) {
                    showCustomCall = true
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    var policyActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Policies")
                .font(.headline)
            
            ForEach(sessionManager.policies.filter { $0.enabled }) { policy in
                PolicyActionCard(policy: policy)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    var customCallSection: some View {
        Button {
            showCustomCall = true
        } label: {
            Label("Custom Contract Call", systemImage: "wrench.and.screwdriver")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.1))
                .foregroundColor(.purple)
                .cornerRadius(10)
        }
    }
    
    var noSessionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No Active Session")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a session in the Setup tab first")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

struct PolicyActionCard: View {
    let policy: PolicyItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(policy.entrypoint)
                    .font(.headline)
                
                Text(policy.contractAddress)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct CustomCallSheet: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPolicyIndex = 0
    @State private var calldataInputs: [String] = ["", "", ""]
    
    var availablePolicies: [PolicyItem] {
        sessionManager.policies.filter { $0.enabled }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    if !availablePolicies.isEmpty {
                        Picker("Policy", selection: $selectedPolicyIndex) {
                            ForEach(0..<availablePolicies.count, id: \.self) { index in
                                Text(availablePolicies[index].entrypoint)
                            }
                        }
                        
                        Text("Contract: \(availablePolicies[selectedPolicyIndex].contractAddress)")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else {
                        Text("No policies available")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Select Policy")
                }
                
                Section {
                    ForEach(0..<3) { index in
                        TextField("Argument \(index + 1)", text: $calldataInputs[index])
                            .font(.system(.body, design: .monospaced))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    Button {
                        calldataInputs.append("")
                    } label: {
                        Label("Add Argument", systemImage: "plus")
                    }
                } header: {
                    Text("Calldata")
                } footer: {
                    Text("Enter the function arguments (usually addresses and amounts in hex)")
                }
                
                // Quick presets for common operations
                Section {
                    if availablePolicies[selectedPolicyIndex].entrypoint == "transfer" {
                        Button("Fill Transfer Example") {
                            calldataInputs = [
                                "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                                "0x1",
                                "0x0"
                            ]
                        }
                    }
                    
                    if availablePolicies[selectedPolicyIndex].entrypoint == "approve" {
                        Button("Fill Approve Example") {
                            calldataInputs = [
                                "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
                                "0x1000",
                                "0x0"
                            ]
                        }
                    }
                } header: {
                    Text("Presets")
                }
                
                Section {
                    Button {
                        Task {
                            let policy = availablePolicies[selectedPolicyIndex]
                            let calldata = calldataInputs.filter { !$0.isEmpty }
                            
                            await sessionManager.executeTransaction(
                                contractAddress: policy.contractAddress,
                                entrypoint: policy.entrypoint,
                                calldata: calldata
                            )
                            
                            if sessionManager.errorMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if sessionManager.isLoading {
                            ProgressView()
                        } else {
                            Text("Execute Transaction")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(sessionManager.isLoading || availablePolicies.isEmpty)
                }
            }
            .navigationTitle("Execute Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExecuteView()
        .environmentObject(SessionManager())
}


