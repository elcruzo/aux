import Foundation

@MainActor
final class URLConversionViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var extractedPlaylist: Playlist?
    @Published private(set) var statusMessage = "Fetching playlist..."
    
    private let url: String
    private let direction: ConversionDirection
    private let coordinator: NavigationCoordinator
    private let apiClient: APIClient
    
    init(
        url: String,
        direction: ConversionDirection,
        coordinator: NavigationCoordinator,
        apiClient: APIClient? = nil
    ) {
        self.url = url
        self.direction = direction
        self.coordinator = coordinator
        self.apiClient = apiClient ?? APIClient.shared
    }
    
    func startConversion() async {
        isLoading = true
        error = nil
        statusMessage = "Extracting playlist information..."
        
        do {
            // Extract playlist ID from URL
            guard let playlistId = extractPlaylistId(from: url) else {
                throw ConversionError.invalidURL
            }
            
            // Fetch playlist info from backend
            statusMessage = "Loading playlist details..."
            let playlist = try await fetchPlaylistInfo(playlistId: playlistId, platform: direction.source)
            extractedPlaylist = playlist
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func convertPlaylist() async {
        guard let playlist = extractedPlaylist else { return }
        
        // Navigate to conversion progress
        coordinator.showConversionProgress(playlist: playlist, direction: direction)
    }
    
    private func extractPlaylistId(from urlString: String) -> String? {
        // Spotify URL formats:
        // https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M
        // spotify:playlist:37i9dQZF1DXcBWIGoYBM5M
        if urlString.contains("spotify") {
            if let match = urlString.range(of: #"playlist[/:]([a-zA-Z0-9]+)"#, options: .regularExpression) {
                let idPart = String(urlString[match])
                return idPart.split(separator: ":").last?.trimmingCharacters(in: .init(charactersIn: "/"))
            }
        }
        
        // Apple Music URL format:
        // https://music.apple.com/us/playlist/todays-hits/pl.f4d106fed2bd41149aaacabb233eb5eb
        if urlString.contains("music.apple.com") {
            if let match = urlString.range(of: #"playlist/[^/]+/(pl\.[a-zA-Z0-9]+)"#, options: .regularExpression) {
                let matched = String(urlString[match])
                return matched.split(separator: "/").last.map(String.init)
            }
        }
        
        return nil
    }
    
    private func fetchPlaylistInfo(playlistId: String, platform: Track.Platform) async throws -> Playlist {
        // For now, create a mock playlist with the ID
        // In a real implementation, this would call the backend API
        return Playlist(
            id: playlistId,
            name: "Loading...",
            description: nil,
            imageUrl: nil,
            trackCount: 0,
            owner: "Unknown",
            platform: platform
        )
    }
    
    enum ConversionError: LocalizedError {
        case invalidURL
        case playlistNotFound
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid playlist URL. Please check the link and try again."
            case .playlistNotFound:
                return "Playlist not found. It may be private or deleted."
            }
        }
    }
}