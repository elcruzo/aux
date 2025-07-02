import Foundation

/// Represents a music track from either Spotify or Apple Music
struct Track: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let artist: String
    let album: String
    let duration: Int // milliseconds
    let isrc: String?
    let platform: Platform
    let uri: String?
    let imageUrl: String?
    
    enum Platform: String, Codable, CaseIterable, Sendable {
        case spotify
        case apple
        
        var displayName: String {
            switch self {
            case .spotify: return "Spotify"
            case .apple: return "Apple Music"
            }
        }
    }
}

/// Represents a playlist from either platform
struct Playlist: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String?
    let imageUrl: String?
    let trackCount: Int
    let owner: String
    let platform: Track.Platform
}

/// Represents a track match during conversion
struct TrackMatch: Codable, Sendable {
    let sourceTrack: Track
    let targetTrack: Track?
    let confidence: Confidence
    let matchType: MatchType?
    
    enum Confidence: String, Codable, Sendable {
        case high
        case medium
        case low
        case none
        
        var displayColor: String {
            switch self {
            case .high: return "green"
            case .medium: return "yellow"
            case .low: return "orange"
            case .none: return "red"
            }
        }
    }
    
    enum MatchType: String, Codable, Sendable {
        case isrc
        case search
        case manual
    }
}

/// Represents the result of a playlist conversion
struct ConversionResult: Codable, Sendable {
    let playlistId: String
    let playlistName: String
    let totalTracks: Int
    let successfulMatches: Int
    let failedMatches: Int
    let matches: [TrackMatch]
    let targetPlaylistId: String?
    let targetPlaylistUrl: String?
}

/// Represents the conversion direction
enum ConversionDirection: String, CaseIterable, Sendable {
    case spotifyToApple = "spotify-to-apple"
    case appleToSpotify = "apple-to-spotify"
    
    var source: Track.Platform {
        switch self {
        case .spotifyToApple: return .spotify
        case .appleToSpotify: return .apple
        }
    }
    
    var target: Track.Platform {
        switch self {
        case .spotifyToApple: return .apple
        case .appleToSpotify: return .spotify
        }
    }
}

/// Conversion progress update
struct ConversionProgress: Sendable {
    let stage: Stage
    let current: Int
    let total: Int
    let message: String
    
    enum Stage: String, Sendable {
        case fetching
        case matching
        case creating
        case adding
        case complete
    }
}