//
//  AccountConnectedCard.swift
//  Sliding card to show successful account connection
//

import SwiftUI

struct AccountConnectedCard: View {
    @EnvironmentObject var sessionManager: SessionManager
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 500
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Card content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 40, height: 6)
                        .padding(.top, 12)
                    
                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 8)
                    
                    // Title
                    Text("Account Connected!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Session Info Card (same as ExecuteView)
                            sessionInfoCard
                                .padding(.horizontal, 20)
                            
                            // Policy Overview
                            policyOverview
                                .padding(.horizontal, 20)
                            
                            // Message
                            Text("Your session is now active. You can execute transactions on the Execute tab.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    .frame(maxHeight: 300)
                    
                    // Continue Button
                    Button {
                        onDismiss()
                    } label: {
                        Text("Continue to Execute")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
                )
                .padding(.horizontal, 16)
                .offset(y: offset)
            }
        }
        .onAppear {
            print("🎨 AccountConnectedCard appeared!")
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                offset = 0
            }
        }
    }
    
    // MARK: - Components (matching ExecuteView style)
    
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
    
    var policyOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Active Policies", systemImage: "checkmark.shield.fill")
                    .font(.headline)
                Spacer()
                Text("\(sessionManager.policies.filter { $0.enabled }.count)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sessionManager.policies.filter { $0.enabled }.prefix(3), id: \.id) { policy in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(policy.entrypoint)
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(policy.contractAddress.prefix(10) + "..." + policy.contractAddress.suffix(6))
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                if sessionManager.policies.filter({ $0.enabled }).count > 3 {
                    Text("+ \(sessionManager.policies.filter({ $0.enabled }).count - 3) more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 24)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    AccountConnectedCard(onDismiss: {})
        .environmentObject(SessionManager())
}

