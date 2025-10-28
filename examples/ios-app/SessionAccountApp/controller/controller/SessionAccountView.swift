//
//  SessionAccountView.swift
//  Main view with tab navigation
//

import SwiftUI

struct SessionAccountView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                SetupView()
                    .tabItem {
                        Label("Setup", systemImage: "gear")
                    }
                    .tag(0)
                
                ExecuteView()
                    .tabItem {
                        Label("Execute", systemImage: "play.circle")
                    }
                    .tag(1)
                
                StatusView()
                    .tabItem {
                        Label("Status", systemImage: "info.circle")
                    }
                    .tag(2)
            }
            
            // Account Connected Card
            if sessionManager.showAccountConnectedCard {
                AccountConnectedCard(
                    username: sessionManager.connectedUsername,
                    publicKey: sessionManager.publicKey,
                    onDismiss: {
                        sessionManager.showAccountConnectedCard = false
                        // Switch to Execute tab
                        withAnimation {
                            selectedTab = 1
                        }
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(100)
            }
            
            // Sliding card overlay
            if sessionManager.showPayloadSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            sessionManager.showPayloadSheet = false
                        }
                    }
                
                SessionPayloadCard()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .alert("Error", isPresented: .constant(sessionManager.errorMessage != nil)) {
            Button("OK") {
                sessionManager.clearError()
            }
        } message: {
            Text(sessionManager.errorMessage ?? "")
        }
        .animation(.spring(), value: sessionManager.showPayloadSheet)
        .animation(.spring(), value: sessionManager.showAccountConnectedCard)
    }
}

#Preview {
    SessionAccountView()
        .environmentObject(SessionManager())
}

