import Foundation
import AuthenticationServices
import UIKit

/// Service for handling Spotify OAuth authentication
@MainActor
final class SpotifyAuthService: NSObject {
    private var authSession: ASWebAuthenticationSession?
    
    func authenticate() async throws {
        let authURL = ServiceFactory.shared.authService.spotifyAuthURL
        let callbackScheme = "aux" // You'll need to register this URL scheme
        
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // The callback will have already set the session cookie
                // Just need to refresh auth status
                continuation.resume()
            }
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            
            self.authSession = session
            
            if !session.start() {
                continuation.resume(throwing: AuthError.sessionFailed)
            }
        }
    }
    
    enum AuthError: LocalizedError {
        case sessionFailed
        
        var errorDescription: String? {
            switch self {
            case .sessionFailed:
                return "Failed to start authentication session"
            }
        }
    }
}

extension SpotifyAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}