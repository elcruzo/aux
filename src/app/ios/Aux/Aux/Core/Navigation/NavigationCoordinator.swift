import Foundation
import SwiftUI

/// Central navigation coordinator for the app
@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedTab: Tab = .converter
    @Published var showingAuth = false
    @Published var authPlatform: Track.Platform?
    @Published var sharedPlaylistUrl: String?
    
    enum Tab: String, CaseIterable {
        case converter
        case history
        case settings
        
        var icon: String {
            switch self {
            case .converter: return "arrow.triangle.2.circlepath"
            case .history: return "clock.arrow.circlepath"
            case .settings: return "gear"
            }
        }
        
        var title: String {
            switch self {
            case .converter: return "Convert"
            case .history: return "History"
            case .settings: return "Settings"
            }
        }
    }
    
    enum Route: Hashable {
        case playlistSelection(direction: ConversionDirection, urlToConvert: String? = nil)
        case conversionProgress(playlist: Playlist, direction: ConversionDirection)
        case conversionResult(result: ConversionResult)
        case playlistDetail(playlist: Playlist)
        
        static func == (lhs: Route, rhs: Route) -> Bool {
            switch (lhs, rhs) {
            case (.playlistSelection(let lDir, let lUrl), .playlistSelection(let rDir, let rUrl)):
                return lDir == rDir && lUrl == rUrl
            case (.conversionProgress(let lPlaylist, let lDir), .conversionProgress(let rPlaylist, let rDir)):
                return lPlaylist == rPlaylist && lDir == rDir
            case (.conversionResult(let lResult), .conversionResult(let rResult)):
                return lResult.playlistId == rResult.playlistId
            case (.playlistDetail(let lPlaylist), .playlistDetail(let rPlaylist)):
                return lPlaylist == rPlaylist
            default:
                return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .playlistSelection(let direction, let url):
                hasher.combine("playlistSelection")
                hasher.combine(direction)
                hasher.combine(url)
            case .conversionProgress(let playlist, let direction):
                hasher.combine("conversionProgress")
                hasher.combine(playlist)
                hasher.combine(direction)
            case .conversionResult(let result):
                hasher.combine("conversionResult")
                hasher.combine(result.playlistId)
            case .playlistDetail(let playlist):
                hasher.combine("playlistDetail")
                hasher.combine(playlist)
            }
        }
    }
    
    // Navigation actions
    func showPlaylistSelection(direction: ConversionDirection, urlToConvert: String? = nil) {
        path.append(Route.playlistSelection(direction: direction, urlToConvert: urlToConvert))
    }
    
    func showConversionProgress(playlist: Playlist, direction: ConversionDirection) {
        path.append(Route.conversionProgress(playlist: playlist, direction: direction))
    }
    
    func showConversionResult(_ result: ConversionResult) {
        // Clear the stack and show result
        path = NavigationPath()
        path.append(Route.conversionResult(result: result))
    }
    
    func showPlaylistDetail(_ playlist: Playlist) {
        path.append(Route.playlistDetail(playlist: playlist))
    }
    
    func showAuthentication(for platform: Track.Platform) {
        authPlatform = platform
        showingAuth = true
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func navigateToConverter() {
        selectedTab = .converter
        path = NavigationPath()
    }
}