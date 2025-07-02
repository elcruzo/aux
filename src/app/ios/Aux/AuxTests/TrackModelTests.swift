import XCTest
@testable import Aux

final class TrackModelTests: XCTestCase {
    
    func testTrackCreation() {
        let track = Track(
            id: "123",
            name: "Test Song",
            artist: "Test Artist",
            album: "Test Album",
            duration: 180000,
            isrc: "USRC12345678",
            platform: .spotify,
            uri: "spotify:track:123",
            imageUrl: nil
        )
        
        XCTAssertEqual(track.id, "123")
        XCTAssertEqual(track.name, "Test Song")
        XCTAssertEqual(track.artist, "Test Artist")
        XCTAssertEqual(track.album, "Test Album")
        XCTAssertEqual(track.duration, 180000)
        XCTAssertEqual(track.isrc, "USRC12345678")
        XCTAssertEqual(track.platform, .spotify)
        XCTAssertEqual(track.uri, "spotify:track:123")
        XCTAssertNil(track.imageUrl)
    }
    
    func testPlatformDisplayName() {
        XCTAssertEqual(Track.Platform.spotify.displayName, "Spotify")
        XCTAssertEqual(Track.Platform.apple.displayName, "Apple Music")
    }
    
    func testConversionDirection() {
        let spotifyToApple = ConversionDirection.spotifyToApple
        XCTAssertEqual(spotifyToApple.source, .spotify)
        XCTAssertEqual(spotifyToApple.target, .apple)
        
        let appleToSpotify = ConversionDirection.appleToSpotify
        XCTAssertEqual(appleToSpotify.source, .apple)
        XCTAssertEqual(appleToSpotify.target, .spotify)
    }
    
    func testTrackMatchConfidence() {
        XCTAssertEqual(TrackMatch.Confidence.high.displayColor, "green")
        XCTAssertEqual(TrackMatch.Confidence.medium.displayColor, "yellow")
        XCTAssertEqual(TrackMatch.Confidence.low.displayColor, "orange")
        XCTAssertEqual(TrackMatch.Confidence.none.displayColor, "red")
    }
}