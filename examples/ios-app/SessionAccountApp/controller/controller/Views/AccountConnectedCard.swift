//
//  AccountConnectedCard.swift
//  Sliding card to show successful account connection
//

import SwiftUI

struct AccountConnectedCard: View {
    let username: String
    let publicKey: String
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 500
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 20) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                .padding(.top, 24)
                
                // Title
                Text("Account Connected!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Account Info
                VStack(spacing: 12) {
                    if !username.isEmpty {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.secondary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Username")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(username)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Public Key")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(publicKey)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                // Message
                Text("Your session is now active. You can execute transactions on the Execute tab.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Continue Button
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        offset = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
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
            .offset(y: offset)
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        offset = 500
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }
        )
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                offset = 0
            }
        }
    }
}

#Preview {
    AccountConnectedCard(
        username: "cartridge_user",
        publicKey: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        onDismiss: {}
    )
}

