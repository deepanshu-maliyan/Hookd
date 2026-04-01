//
//  HookdApp.swift
//  Hookd
//
//  Created by Deepanshu Maliyaan on 01/04/26.
//

import SwiftUI

@main
struct HookdApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
