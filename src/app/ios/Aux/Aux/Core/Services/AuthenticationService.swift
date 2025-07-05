import Foundation
import Combine

/// Service for managing authentication state
@MainActor
final class AuthenticationService: ObservableObject {
    @Published private(set) var isSpotifyAuthenticated = false
    @Published private(set) var isAppleAuthenticated = false
    
    private let apiClient: APIClient
    private let keychain = KeychainService.shared
    private var cancellables = Set<AnyCancellable>()
    private var isCheckingAuth = false
    private var lastAuthCheck: Date?
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
        
        // Check local keychain auth on init
        checkLocalAuthStatus()
    }
    
    /// Check local keychain for stored auth
    private func checkLocalAuthStatus() {
        isSpotifyAuthenticated = keychain.hasSpotifyAuth() && !keychain.isSpotifyTokenExpired()
        
        // For Apple, only check keychain - don't access MusicAuthorization here
        // as it might be too early in the app lifecycle
        isAppleAuthenticated = keychain.hasAppleAuth()
        
        print("🔐 Local auth check:")
        print("   Spotify: \(isSpotifyAuthenticated ? "Found valid token" : "No valid token")")
        print("   Apple: \(isAppleAuthenticated ? "Found token" : "No token")")
    }
    
    /// Check authentication status for both platforms
    func checkAuthStatus() async {
        // Prevent duplicate checks within 2 seconds
        if isCheckingAuth {
            print("🔐 Skipping duplicate auth check (already in progress)")
            return
        }
        
        if let lastCheck = lastAuthCheck, Date().timeIntervalSince(lastCheck) < 2.0 {
            print("🔐 Skipping auth check (checked recently)")
            return
        }
        
        isCheckingAuth = true
        defer { 
            isCheckingAuth = false
            lastAuthCheck = Date()
        }
        
        print("🔐 Checking auth status with server...")
        print("   URL: \(AppConfiguration.apiBaseURL)/auth/status")
        
        do {
            let status = try await apiClient.getAuthStatus()
            
            // Update local state
            isSpotifyAuthenticated = status.spotify
            isAppleAuthenticated = status.apple
            
            print("✅ Auth check successful!")
            print("   Spotify: \(status.spotify ? "Authenticated" : "Not authenticated")")
            print("   Apple: \(status.apple ? "Authenticated" : "Not authenticated")")
            
            // Sync with keychain if server says we're not authenticated
            if !status.spotify {
                try? keychain.delete(key: .spotifyAccessToken)
                try? keychain.delete(key: .spotifyRefreshToken)
                try? keychain.delete(key: .spotifyTokenExpiry)
            }
            if !status.apple {
                try? keychain.delete(key: .appleUserToken)
            }
        } catch {
            print("❌ Failed to check auth status")
            print("   Error: \(error)")
            print("   Using local keychain auth status")
            // Fall back to local keychain status
            checkLocalAuthStatus()
        }
    }
    
    /// Save Apple Music token after authentication
    func saveAppleToken(_ token: String) async throws {
        // Save to keychain first
        try keychain.save(token, for: .appleUserToken)
        
        // Then save to server
        try await apiClient.saveAppleToken(token)
        
        // Update local state
        isAppleAuthenticated = true
    }
    
    /// Save Spotify tokens after authentication
    func saveSpotifyTokens(accessToken: String, refreshToken: String?, expiresIn: Int) throws {
        // Save tokens to keychain
        try keychain.save(accessToken, for: .spotifyAccessToken)
        
        if let refreshToken = refreshToken {
            try keychain.save(refreshToken, for: .spotifyRefreshToken)
        }
        
        // Save expiry time
        let expiryTime = Date().timeIntervalSince1970 + Double(expiresIn)
        try keychain.save(String(expiryTime), for: .spotifyTokenExpiry)
        
        // Update local state
        isSpotifyAuthenticated = true
        
        print("💾 Saved Spotify tokens to keychain")
        print("   Expires in: \(expiresIn) seconds")
    }
    
    /// Clear all authentication data
    func logout() {
        keychain.clearAll()
        isSpotifyAuthenticated = false
        isAppleAuthenticated = false
        print("🚪 Logged out - cleared all keychain data")
    }
    
    /// Get Spotify auth URL for web-based OAuth
    var spotifyAuthURL: URL {
        URL(string: "\(AppConfiguration.apiBaseURL)/auth/spotify")!
    }
    
    /// Get stored Spotify access token
    func getSpotifyAccessToken() -> String? {
        try? keychain.getString(for: .spotifyAccessToken)
    }
    
    /// Get stored Apple user token
    func getAppleUserToken() -> String? {
        try? keychain.getString(for: .appleUserToken)
    }
}