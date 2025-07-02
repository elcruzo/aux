import Foundation
import Combine

@MainActor
final class ConverterViewModel: ObservableObject {
    @Published var direction = ConversionDirection.spotifyToApple
    @Published private(set) var sourceAuthenticated = false
    @Published private(set) var targetAuthenticated = false
    
    private let authService: AuthenticationService
    private let coordinator: NavigationCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    var canConvert: Bool {
        sourceAuthenticated && targetAuthenticated
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
    
    func startConversion() {
        coordinator.showPlaylistSelection(direction: direction)
    }
    
    func checkAuthStatus() async {
        await authService.checkAuthStatus()
    }
}