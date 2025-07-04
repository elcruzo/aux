//
//  AuxApp.swift
//  Aux
//
//  Created by Ayomide Adekoya on 7/1/25.
//

import SwiftUI
import UIKit

@main
struct AuxApp: App {
    @StateObject private var coordinator = NavigationCoordinator()
    @State private var showLaunchScreen = true
    @State private var showOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                } else if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                        .transition(.opacity)
                } else {
                    RootView()
                        .environmentObject(coordinator)
                        .tint(Color.accentColor)
                        .onOpenURL { url in
                            handleDeepLink(url)
                        }
                }
            }
            .onAppear {
                // Log app startup
                print("\n🚀 AUX APP STARTING")
                print("🌐 API URL: \(AppConfiguration.apiBaseURL)")
                print("📱 Device: \(UIDevice.current.name)")
                print("\n")
                
                // Check if onboarding has been completed
                let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunchScreen = false
                        if !hasCompletedOnboarding {
                            showOnboarding = true
                        }
                    }
                }
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle aux://convert?url=<encoded_playlist_url>
        guard url.scheme == "aux" else { return }
        
        if url.host == "convert",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
           let playlistUrl = urlParam.removingPercentEncoding {
            
            // Navigate to converter with the playlist URL
            coordinator.sharedPlaylistUrl = playlistUrl
            coordinator.navigateToConverter()
        }
    }
}
