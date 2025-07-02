//
//  AuxApp.swift
//  Aux
//
//  Created by Ayomide Adekoya on 7/1/25.
//

import SwiftUI

@main
struct AuxApp: App {
    @StateObject private var coordinator = NavigationCoordinator()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .tint(.primary) // Use system default tint
        }
    }
}
