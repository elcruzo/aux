import Foundation
import MusicKit

/// Service for handling Apple Music authentication
@MainActor
final class AppleAuthService {
    func authenticate() async throws -> String {
        let status = await MusicAuthorization.request()
        
        guard status == .authorized else {
            throw AuthError.notAuthorized
        }
        
        // For iOS apps using MusicKit, the token is managed automatically
        // Return a placeholder token since MusicKit handles authentication internally
        return "apple_music_authorized"
    }
    
    var isAuthorized: Bool {
        MusicAuthorization.currentStatus == .authorized
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