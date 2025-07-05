import Foundation
import Combine

@MainActor
final class ConverterViewModel: ObservableObject {
    @Published var direction = ConversionDirection.spotifyToApple
    @Published private(set) var sourceAuthenticated = false
    @Published private(set) var targetAuthenticated = false
    @Published var urlInput = ""
    
    private let authService: AuthenticationService
    private let coordinator: NavigationCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    var canSelectPlaylist: Bool {
        targetAuthenticated
    }
    
    var isValidURL: Bool {
        guard !urlInput.isEmpty else { return false }
        return urlInput.contains("spotify.com") || 
               urlInput.contains("music.apple.com") || 
               urlInput.starts(with: "spotify:")
    }
    
    var sourcePlatform: Track.Platform {
        direction.source
    }
    
    var targetPlatform: Track.Platform {
        direction.target
    }
    
    init(
        coordinator: NavigationCoordinator,
        authService: AuthenticationService? = nil
    ) {
        self.authService = authService ?? ServiceFactory.shared.authService
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Observe auth changes
        authService.$isSpotifyAuthenticated
            .combineLatest(authService.$isAppleAuthenticated, $direction)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spotify, apple, direction in
                self?.updateAuthStatus(spotify: spotify, apple: apple, direction: direction)
            }
            .store(in: &cancellables)
        
        // Observe shared playlist URL
        coordinator.$sharedPlaylistUrl
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                self?.handleSharedUrl(url)
            }
            .store(in: &cancellables)
    }
    
    private func updateAuthStatus(spotify: Bool, apple: Bool, direction: ConversionDirection) {
        switch direction {
        case .spotifyToApple:
            sourceAuthenticated = spotify
            targetAuthenticated = apple
        case .appleToSpotify:
            sourceAuthenticated = apple
            targetAuthenticated = spotify
        }
    }
    
    func authenticateSource() {
        coordinator.showAuthentication(for: sourcePlatform)
    }
    
    func authenticateTarget() {
        coordinator.showAuthentication(for: targetPlatform)
    }
    
    // Removed - no longer needed since we're using URL-based conversion only
    
    func checkAuthStatus() async {
        await authService.checkAuthStatus()
    }
    
    func convertFromURL() {
        guard isValidURL else { return }
        handleSharedUrl(urlInput)
        urlInput = "" // Clear after processing
    }
    
    private func handleSharedUrl(_ urlString: String) {
        // Clear the shared URL so we don't process it multiple times
        coordinator.sharedPlaylistUrl = nil
        
        // Determine platform from URL
        let isSpotifyUrl = urlString.contains("spotify.com") || urlString.starts(with: "spotify:")
        let isAppleUrl = urlString.contains("music.apple.com")
        
        guard isSpotifyUrl || isAppleUrl else { return }
        
        // Determine the target platform based on URL
        let targetPlatform: Track.Platform
        if isSpotifyUrl {
            targetPlatform = .apple
            direction = .spotifyToApple
        } else if isAppleUrl {
            targetPlatform = .spotify
            direction = .appleToSpotify
        } else {
            return
        }
        
        // Check if user has the target platform authenticated
        let targetAuthenticated = (targetPlatform == .spotify) ? authService.isSpotifyAuthenticated : authService.isAppleAuthenticated
        
        if targetAuthenticated {
            // User has the platform they need, proceed to conversion
            coordinator.showURLConversion(url: urlString, direction: direction)
        } else {
            // User needs to authenticate the target platform
            coordinator.showAuthentication(for: targetPlatform)
        }
    }
}