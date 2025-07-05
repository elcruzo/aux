import Foundation
import MusicKit

/// Service for handling Apple Music authentication
@MainActor
final class AppleAuthService {
    /// Track if we've performed initial setup
    private var hasPerformedInitialCheck = false
    
    func authenticate() async throws -> String {
        // Mark that we've performed a check when user explicitly authenticates
        hasPerformedInitialCheck = true
        
        let status = await MusicAuthorization.request()
        
        guard status == .authorized else {
            throw AuthError.notAuthorized
        }
        
        // For iOS apps using MusicKit, the token is managed automatically
        // Return a placeholder token since MusicKit handles authentication internally
        return "apple_music_authorized"
    }
    
    var isAuthorized: Bool {
        // NEVER check MusicAuthorization.currentStatus directly
        // This can cause privacy crashes if called at wrong time
        // Only return true if we have a token in keychain
        return KeychainService.shared.hasAppleAuth()
    }
    
    /// Safely check authorization status after app is ready
    func checkAuthorizationStatus() async -> Bool {
        // Only check if we've explicitly authenticated before
        guard hasPerformedInitialCheck else { return false }
        
        return MusicAuthorization.currentStatus == .authorized
    }
    
    enum AuthError: LocalizedError {
        case notAuthorized
        case noToken
        
        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Apple Music authorization denied"
            case .noToken:
                return "Failed to get Apple Music user token"
            }
        }
    }
}