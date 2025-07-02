import Foundation
import Combine

/// Service for managing authentication state
@MainActor
final class AuthenticationService: ObservableObject {
    @Published private(set) var isSpotifyAuthenticated = false
    @Published private(set) var isAppleAuthenticated = false
    
    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    /// Check authentication status for both platforms
    func checkAuthStatus() async {
        do {
            let status = try await apiClient.getAuthStatus()
            isSpotifyAuthenticated = status.spotify
            isAppleAuthenticated = status.apple
        } catch {
            print("Failed to check auth status: \(error)")
            isSpotifyAuthenticated = false
            isAppleAuthenticated = false
        }
    }
    
    /// Save Apple Music token after authentication
    func saveAppleToken(_ token: String) async throws {
        try await apiClient.saveAppleToken(token)
        await checkAuthStatus()
    }
    
    /// Get Spotify auth URL for web-based OAuth
    var spotifyAuthURL: URL {
        // In production, this would be your deployed URL
        URL(string: "http://127.0.0.1:3000/api/auth/spotify")!
    }
}