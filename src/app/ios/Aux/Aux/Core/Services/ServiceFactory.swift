import Foundation

/// Factory for creating and managing service instances with lazy initialization
@MainActor
final class ServiceFactory {
    static let shared = ServiceFactory()
    
    // Lazy initialization of services
    private lazy var _authService = AuthenticationService(apiClient: APIClient.shared)
    private lazy var _playlistService = PlaylistService(apiClient: APIClient.shared)
    private lazy var _conversionService = ConversionService(
        apiClient: APIClient.shared,
        playlistService: _playlistService
    )
    private lazy var _spotifyAuthService = SpotifyAuthService()
    private lazy var _appleAuthService = AppleAuthService()
    private lazy var _historyService = ConversionHistoryService.shared
    
    private init() {}
    
    // Public accessors
    var authService: AuthenticationService { _authService }
    var playlistService: PlaylistService { _playlistService }
    var conversionService: ConversionService { _conversionService }
    var spotifyAuthService: SpotifyAuthService { _spotifyAuthService }
    var appleAuthService: AppleAuthService { _appleAuthService }
    var historyService: ConversionHistoryService { _historyService }
}