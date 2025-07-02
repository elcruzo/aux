import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(NavigationCoordinator.Tab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .sheet(isPresented: $coordinator.showingAuth) {
            if let platform = coordinator.authPlatform {
                NavigationStack {
                    AuthenticationView(platform: platform, coordinator: coordinator)
                        .navigationBarItems(
                            trailing: Button("Cancel") {
                                coordinator.showingAuth = false
                            }
                        )
                }
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: NavigationCoordinator.Tab) -> some View {
        switch tab {
        case .converter:
            NavigationStack(path: $coordinator.path) {
                ConverterView(coordinator: coordinator)
                    .navigationDestination(for: NavigationCoordinator.Route.self) { route in
                        destinationView(for: route)
                    }
            }
            
        case .history:
            NavigationStack {
                HistoryView()
            }
            
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: NavigationCoordinator.Route) -> some View {
        switch route {
        case .playlistSelection(let direction):
            PlaylistSelectionView(direction: direction, coordinator: coordinator)
            
        case .conversionProgress(let playlist, let direction):
            ConversionProgressView(
                playlist: playlist,
                direction: direction,
                coordinator: coordinator
            )
            
        case .conversionResult(let result):
            ConversionResultView(result: result, coordinator: coordinator)
            
        case .playlistDetail(let playlist):
            PlaylistDetailView(playlist: playlist)
        }
    }
}


struct SettingsView: View {
    var body: some View {
        List {
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                Link("GitHub", destination: URL(string: "https://github.com/elcruzo/aux")!)
            }
            
            Section("Developer") {
                Link("API Documentation", destination: URL(string: AppConfiguration.apiDocsURL)!)
                Link("API Playground", destination: URL(string: AppConfiguration.apiDocsURL)!)
                Link("GitHub Issues", destination: URL(string: "https://github.com/elcruzo/aux/issues")!)
            }
            
            Section("Resources") {
                Link("Spotify Web API", destination: URL(string: "https://developer.spotify.com/documentation/web-api")!)
                Link("Apple Music API", destination: URL(string: "https://developer.apple.com/documentation/applemusicapi")!)
            }
        }
        .navigationTitle("Settings")
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    
    var body: some View {
        Text("Playlist: \(playlist.name)")
            .navigationTitle(playlist.name)
    }
}

#Preview {
    RootView()
        .environmentObject(NavigationCoordinator())
}
