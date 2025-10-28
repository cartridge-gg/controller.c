//
//  ContentView.swift
//  Main app view with tab navigation
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var controllerManager: ControllerManager
    
    var body: some View {
        TabView {
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
            
            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "arrow.left.arrow.right")
                }
            
            SessionView()
                .tabItem {
                    Label("Sessions", systemImage: "clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ControllerManager())
}


