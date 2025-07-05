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
        case .urlConversion(let url, let direction):
            URLConversionView(url: url, direction: direction, coordinator: coordinator)
            
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
