//
//  SessionAccountView.swift
//  Main view with tab navigation
//

import SwiftUI

struct SessionAccountView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab = 0
    
    var body: some View {
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
        .alert("Error", isPresented: .constant(sessionManager.errorMessage != nil)) {
            Button("OK") {
                sessionManager.clearError()
            }
        } message: {
            Text(sessionManager.errorMessage ?? "")
        }
        .alert("Success", isPresented: .constant(sessionManager.successMessage != nil)) {
            Button("OK") {
                sessionManager.clearSuccess()
            }
        } message: {
            Text(sessionManager.successMessage ?? "")
        }
    }
}

#Preview {
    SessionAccountView()
        .environmentObject(SessionManager())
}


