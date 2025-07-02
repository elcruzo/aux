import Foundation
import Combine

@MainActor
final class PlaylistSelectionViewModel: ObservableObject {
    @Published var searchText = ""
    @Published private(set) var playlists: [Playlist] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    let direction: ConversionDirection
    private let playlistService: PlaylistService
    private let coordinator: NavigationCoordinator
    
    var filteredPlaylists: [Playlist] {
        if searchText.isEmpty {
            return playlists
        }
        return playlists.filter { playlist in
            playlist.name.localizedCaseInsensitiveContains(searchText) ||
            playlist.owner.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    init(
        direction: ConversionDirection,
        coordinator: NavigationCoordinator,
        playlistService: PlaylistService? = nil
    ) {
        self.direction = direction
        self.playlistService = playlistService ?? ServiceFactory.shared.playlistService
        self.coordinator = coordinator
    }
    
    func loadPlaylists() async {
        isLoading = true
        error = nil
        
        await playlistService.fetchPlaylists(for: direction.source)
        playlists = playlistService.playlists(for: direction.source)
        
        if let error = playlistService.error {
            self.error = error
        }
        
        isLoading = false
    }
    
    func selectPlaylist(_ playlist: Playlist) {
        coordinator.showConversionProgress(playlist: playlist, direction: direction)
    }
}