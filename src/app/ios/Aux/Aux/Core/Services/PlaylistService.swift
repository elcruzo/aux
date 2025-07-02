import Foundation
import Combine

/// Service for managing playlist operations
@MainActor
final class PlaylistService: ObservableObject {
    @Published private(set) var spotifyPlaylists: [Playlist] = []
    @Published private(set) var applePlaylists: [Playlist] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    /// Fetch playlists for the specified platform
    func fetchPlaylists(for platform: Track.Platform) async {
        isLoading = true
        error = nil
        
        do {
            switch platform {
            case .spotify:
                spotifyPlaylists = try await apiClient.getSpotifyPlaylists()
            case .apple:
                applePlaylists = try await apiClient.getApplePlaylists()
            }
        } catch {
            self.error = error
            print("Failed to fetch playlists: \(error)")
        }
        
        isLoading = false
    }
    
    /// Get playlists for the specified platform
    func playlists(for platform: Track.Platform) -> [Playlist] {
        switch platform {
        case .spotify:
            return spotifyPlaylists
        case .apple:
            return applePlaylists
        }
    }
    
    /// Fetch tracks for a specific playlist
    func fetchTracks(for playlist: Playlist) async throws -> [Track] {
        try await apiClient.getPlaylistTracks(
            playlistId: playlist.id,
            platform: playlist.platform
        )
    }
}