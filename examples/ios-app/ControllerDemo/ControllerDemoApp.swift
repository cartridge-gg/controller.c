//
//  ControllerDemoApp.swift
//  Cartridge Controller iOS Demo
//
//  Demonstrates integration of Cartridge Controller in an iOS app
//

import SwiftUI

@main
struct ControllerDemoApp: App {
    @StateObject private var controllerManager = ControllerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(controllerManager)
        }
    }
}


