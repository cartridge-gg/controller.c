//
//  SessionPayloadView.swift
//  Display decoded session payload as a sliding card
//

import SwiftUI

struct SessionPayloadCard: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var dragOffset: CGFloat = 0
    
    var formattedJSON: String {
        guard let payload = sessionManager.sessionPayload,
              let data = payload.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return sessionManager.sessionPayload ?? "No payload"
        }
        return prettyString
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Success header
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Session Created!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Authorization successful")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Payload section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Session Data")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(formattedJSON)
                                .font(.system(.caption, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    // Actions
                    HStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = sessionManager.sessionPayload
                        } label: {
                            Label("Copy Raw", systemImage: "doc.on.doc")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            UIPasteboard.general.string = formattedJSON
                        } label: {
                            Label("Copy JSON", systemImage: "doc.on.clipboard")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            sessionManager.showPayloadSheet = false
                        }
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 20)
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(.spring()) {
                            sessionManager.showPayloadSheet = false
                        }
                    }
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct SessionPayloadView: View {
    var body: some View {
        SessionPayloadCard()
    }
}

#Preview {
    SessionPayloadView()
        .environmentObject(SessionManager())
}

