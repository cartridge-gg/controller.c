//
//  SessionAccountApp.swift
//  Session Account Demo App
//

import SwiftUI

@main
struct SessionAccountApp: App {
    @StateObject private var sessionManager = SessionManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            SessionAccountView()
                .environmentObject(sessionManager)
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        // Auto-try to create session when returning from browser
                        Task {
                            await sessionManager.tryAutoCreateSession()
                        }
                    }
                }
                .onOpenURL { url in
                    // Handle deep link callback from Cartridge
                    if url.scheme == "sessionaccount" {
                        withAnimation(.spring()) {
                            sessionManager.handleDeepLink(url: url)
                        }
                    }
                }
        }
    }
}

