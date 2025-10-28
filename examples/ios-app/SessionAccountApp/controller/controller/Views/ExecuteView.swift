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
                        // Session Info Card
                        sessionInfoCard
                        
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
    
    var sessionInfoCard: some View {
        let isExpired = sessionManager.sessionAccount?.isExpired() ?? false
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isExpired ? "exclamationmark.triangle.fill" : "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(isExpired ? .red : .green)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let username = sessionManager.sessionUsername {
                        Text(username)
                            .font(.headline)
                    } else if let ownerGuid = sessionManager.sessionOwnerGuid {
                        Text(ownerGuid.prefix(10) + "..." + ownerGuid.suffix(6))
                            .font(.system(.headline, design: .monospaced))
                    } else {
                        Text("Session Active")
                            .font(.headline)
                    }
                    
                    if isExpired {
                        Label("Session Expired", systemImage: "xmark.circle")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if sessionManager.isRevoked {
                        Label("Session Revoked", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Label("Ready to Execute", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                if let expiresAt = sessionManager.sessionExpiresAt {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Expires")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(Date(timeIntervalSince1970: TimeInterval(expiresAt)), style: .relative)
                            .font(.caption)
                            .foregroundColor(isExpired ? .red : .orange)
                    }
                }
            }
            
            if let address = sessionManager.sessionAddress {
                Divider()
                HStack {
                    Text("Address:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(address.prefix(10) + "..." + address.suffix(6))
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .padding()
        .background(isExpired ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
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
    @State private var arguments: [TransactionArgument] = []
    
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
                    ForEach(arguments.indices, id: \.self) { index in
                        ArgumentRow(argument: $arguments[index], index: index, onDelete: {
                            arguments.remove(at: index)
                        })
                    }
                    
                    Button {
                        arguments.append(TransactionArgument())
                    } label: {
                        Label("Add Argument", systemImage: "plus")
                    }
                } header: {
                    Text("Arguments")
                } footer: {
                    Text("Specify argument type for automatic conversion")
                }
                
                // Quick presets for common operations
                Section {
                    if !availablePolicies.isEmpty && availablePolicies[selectedPolicyIndex].entrypoint == "transfer" {
                        Button("Fill Transfer Example") {
                            arguments = [
                                TransactionArgument(type: .address, value: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"),
                                TransactionArgument(type: .u256, value: "1000")
                            ]
                        }
                    }
                    
                    if !availablePolicies.isEmpty && availablePolicies[selectedPolicyIndex].entrypoint == "approve" {
                        Button("Fill Approve Example") {
                            arguments = [
                                TransactionArgument(type: .address, value: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"),
                                TransactionArgument(type: .u256, value: "10000")
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
                            
                            // Convert all arguments to calldata
                            let calldata = arguments.flatMap { $0.toCalldata() }
                            
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
                    .disabled(sessionManager.isLoading || availablePolicies.isEmpty || arguments.isEmpty)
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
            .onAppear {
                if arguments.isEmpty {
                    // Start with two default arguments
                    arguments = [TransactionArgument(), TransactionArgument(type: .u256)]
                }
            }
        }
    }
}

struct ArgumentRow: View {
    @Binding var argument: TransactionArgument
    let index: Int
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Arg \(index + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("", selection: $argument.type) {
                    ForEach(ArgumentType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption)
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
            
            TextField(argument.type.placeholder, text: $argument.value)
                .font(.system(.body, design: .monospaced))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            Text(argument.type.description)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            // Show preview of what will be sent
            if !argument.value.isEmpty {
                let calldata = argument.toCalldata()
                if calldata.count > 1 {
                    Text("→ \(calldata.count) felts: \(calldata.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExecuteView()
        .environmentObject(SessionManager())
}

