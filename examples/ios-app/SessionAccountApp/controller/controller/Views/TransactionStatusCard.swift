//
//  TransactionStatusCard.swift
//  Shows transaction status with confirmation tracking
//

import SwiftUI

struct TransactionStatusCard: View {
    let transactionHash: String
    let isConfirmed: Bool
    let onDismiss: () -> Void
    
    @State private var offset: CGFloat = 500
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if isConfirmed {
                        onDismiss()
                    }
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
                    
                    // Status Icon
                    ZStack {
                        Circle()
                            .fill(isConfirmed ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        if isConfirmed {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.5)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Title
                    Text(isConfirmed ? "Transaction Confirmed!" : "Transaction Sent")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Status message
                    Text(isConfirmed ? "Your transaction has been confirmed on-chain" : "Waiting for confirmation...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Transaction Hash Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text("Transaction Hash")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            Text(transactionHash.prefix(10) + "..." + transactionHash.suffix(10))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button {
                                UIPasteboard.general.string = transactionHash
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Image(systemName: isConfirmed ? "checkmark.circle.fill" : "clock.fill")
                                .foregroundColor(isConfirmed ? .green : .orange)
                            Text(isConfirmed ? "Confirmed" : "Pending")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button {
                            if let url = URL(string: "https://sepolia.starkscan.co/tx/\(transactionHash)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.right.square")
                                Text("View on Explorer")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        if isConfirmed {
                            Button {
                                onDismiss()
                            } label: {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
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
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                offset = 0
            }
        }
    }
}

#Preview {
    TransactionStatusCard(
        transactionHash: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
        isConfirmed: false,
        onDismiss: {}
    )
}

