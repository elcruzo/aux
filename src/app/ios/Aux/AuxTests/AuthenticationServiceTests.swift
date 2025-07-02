import XCTest
@testable import Aux

@MainActor
final class AuthenticationServiceTests: XCTestCase {
    var sut: AuthenticationService!
    var mockAPIClient: APIClient!
    
    override func setUp() async throws {
        try await super.setUp()
        mockAPIClient = APIClient.shared
        sut = AuthenticationService(apiClient: mockAPIClient)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockAPIClient = nil
        try await super.tearDown()
    }
    
    func testInitialAuthState() {
        XCTAssertFalse(sut.isSpotifyAuthenticated)
        XCTAssertFalse(sut.isAppleAuthenticated)
    }
    
    func testSpotifyAuthURL() {
        let url = sut.spotifyAuthURL
        XCTAssertTrue(url.absoluteString.contains("auth/spotify"))
    }
}