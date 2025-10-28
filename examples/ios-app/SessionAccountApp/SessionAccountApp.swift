//
//  SessionAccountApp.swift
//  Session Account Demo App
//

import SwiftUI

@main
struct SessionAccountApp: App {
    @StateObject private var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            SessionAccountView()
                .environmentObject(sessionManager)
        }
    }
}


