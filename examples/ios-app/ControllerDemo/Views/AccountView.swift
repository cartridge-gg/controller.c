//
//  AccountView.swift
//  Account management and creation
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var controllerManager: ControllerManager
    @State private var usernameInput = ""
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let controller = controllerManager.controller {
                        // Existing account view
                        accountInfoCard
                        actionsSection
                    } else {
                        // No account view
                        emptyStateView
                    }
                    
                    if controllerManager.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Account")
            .alert("Error", isPresented: .constant(controllerManager.errorMessage != nil)) {
                Button("OK") {
                    controllerManager.clearError()
                }
            } message: {
                Text(controllerManager.errorMessage ?? "")
            }
            .alert("Success", isPresented: .constant(controllerManager.successMessage != nil)) {
                Button("OK") {
                    controllerManager.clearSuccess()
                }
            } message: {
                Text(controllerManager.successMessage ?? "")
            }
            .sheet(isPresented: $showCreateSheet) {
                createAccountSheet
            }
        }
    }
    
    // MARK: - Components
    
    var accountInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(controllerManager.username ?? "Unknown")
                        .font(.headline)
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Address", value: controllerManager.controllerAddress ?? "N/A")
                InfoRow(label: "Network", value: "Sepolia")
                InfoRow(label: "App ID", value: controllerManager.appId)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await controllerManager.signup()
                }
            } label: {
                HStack {
                    Image(systemName: "rocket")
                    Text("Deploy Account")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(controllerManager.isLoading)
            
            Button {
                if let address = controllerManager.controllerAddress {
                    UIPasteboard.general.string = address
                    controllerManager.successMessage = "Address copied!"
                }
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Address")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Account")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Create a controller account to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showCreateSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Account")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var createAccountSheet: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Username", text: $usernameInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Account Details")
                } footer: {
                    Text("Choose a unique username for your account")
                }
                
                Section {
                    Button {
                        Task {
                            await controllerManager.createController(username: usernameInput)
                            if controllerManager.controller != nil {
                                showCreateSheet = false
                                usernameInput = ""
                            }
                        }
                    } label: {
                        Text("Create")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(usernameInput.isEmpty || controllerManager.isLoading)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCreateSheet = false
                        usernameInput = ""
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(ControllerManager())
}


