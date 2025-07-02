import Foundation

/// Authentication status for each platform
struct AuthStatus: Codable, Sendable {
    let spotify: Bool
    let apple: Bool
}