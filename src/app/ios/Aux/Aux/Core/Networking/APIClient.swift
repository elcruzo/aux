import Foundation

/// Main API client for communicating with the Aux backend
actor APIClient: Sendable {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        self.baseURL = URL(string: AppConfiguration.apiBaseURL)!
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    enum APIError: LocalizedError {
        case invalidURL
        case noData
        case decodingError(Error)
        case serverError(String)
        case networkError(Error)
        case unauthorized
        case timeout
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError(let error):
                return "Failed to decode response: \(error.localizedDescription)"
            case .serverError(let message):
                return message
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .unauthorized:
                return "Please authenticate first"
            case .timeout:
                return "Request timed out. Please check your connection."
            }
        }
    }
}

// MARK: - Request Methods
extension APIClient {
    func get<T: Decodable>(_ endpoint: String, type: T.Type) async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    if let errorData = try? decoder.decode(ErrorResponse.self, from: data) {
                        throw APIError.serverError(errorData.error)
                    }
                    throw APIError.serverError("Client error: \(httpResponse.statusCode)")
                case 500...599:
                    throw APIError.serverError("Server error: \(httpResponse.statusCode)")
                default:
                    throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func post<T: Encodable, R: Decodable>(_ endpoint: String, body: T, responseType: R.Type) async throws -> R {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break // Success
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    if let errorData = try? decoder.decode(ErrorResponse.self, from: data) {
                        throw APIError.serverError(errorData.error)
                    }
                    throw APIError.serverError("Client error: \(httpResponse.statusCode)")
                case 500...599:
                    throw APIError.serverError("Server error: \(httpResponse.statusCode)")
                default:
                    throw APIError.serverError("Unexpected status code: \(httpResponse.statusCode)")
                }
            }
            
            do {
                return try decoder.decode(R.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Authentication
extension APIClient {
    func getAuthStatus() async throws -> AuthStatus {
        try await get("/auth/status", type: AuthStatus.self)
    }
    
    func saveAppleToken(_ token: String) async throws {
        struct Request: Encodable {
            let musicUserToken: String
            let expiresAt: TimeInterval
        }
        
        struct Response: Decodable {
            let success: Bool
        }
        
        let request = Request(
            musicUserToken: token,
            expiresAt: Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970 * 1000
        )
        
        _ = try await post("/auth/apple/callback", body: request, responseType: Response.self)
    }
}

// MARK: - Playlists
extension APIClient {
    func getSpotifyPlaylists() async throws -> [Playlist] {
        try await get("/spotify/playlists", type: [Playlist].self)
    }
    
    func getApplePlaylists() async throws -> [Playlist] {
        try await get("/apple/playlists", type: [Playlist].self)
    }
    
    func getPlaylistTracks(playlistId: String, platform: Track.Platform) async throws -> [Track] {
        let endpoint = platform == .spotify 
            ? "/spotify/playlists/\(playlistId)/tracks"
            : "/apple/playlists/\(playlistId)/tracks"
        return try await get(endpoint, type: [Track].self)
    }
}

// MARK: - Conversion
extension APIClient {
    func convertPlaylist(playlistId: String, playlistName: String, direction: ConversionDirection) async throws -> ConversionResult {
        struct Request: Encodable {
            let playlistId: String
            let playlistName: String
            let direction: String
        }
        
        let request = Request(
            playlistId: playlistId,
            playlistName: playlistName,
            direction: direction.rawValue
        )
        
        return try await post("/convert", body: request, responseType: ConversionResult.self)
    }
}

// MARK: - Helper Types
private struct ErrorResponse: Decodable {
    let error: String
}