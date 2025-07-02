import Foundation
import Combine

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let authService: AuthenticationService
    private let spotifyAuthService: SpotifyAuthService
    private let appleAuthService: AppleAuthService
    private let coordinator: NavigationCoordinator
    
    var isSpotifyAuthenticated: Bool {
        authService.isSpotifyAuthenticated
    }
    
    var isAppleAuthenticated: Bool {
        authService.isAppleAuthenticated
    }
    
    init(
        coordinator: NavigationCoordinator,
        authService: AuthenticationService? = nil,
        spotifyAuthService: SpotifyAuthService? = nil,
        appleAuthService: AppleAuthService? = nil
    ) {
        self.authService = authService ?? ServiceFactory.shared.authService
        self.spotifyAuthService = spotifyAuthService ?? ServiceFactory.shared.spotifyAuthService
        self.appleAuthService = appleAuthService ?? ServiceFactory.shared.appleAuthService
        self.coordinator = coordinator
    }
    
    func authenticateSpotify() async {
        isLoading = true
        error = nil
        
        do {
            try await spotifyAuthService.authenticate()
            await authService.checkAuthStatus()
            
            if isSpotifyAuthenticated {
                coordinator.showingAuth = false
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func authenticateApple() async {
        isLoading = true
        error = nil
        
        do {
            let token = try await appleAuthService.authenticate()
            try await authService.saveAppleToken(token)
            
            if isAppleAuthenticated {
                coordinator.showingAuth = false
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func checkAuthStatus() async {
        await authService.checkAuthStatus()
    }
}