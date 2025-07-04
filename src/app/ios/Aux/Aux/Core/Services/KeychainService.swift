import Foundation
import Security

/// Service for securely storing sensitive data in iOS Keychain
final class KeychainService {
    static let shared = KeychainService()
    
    private let serviceName = "com.aux.app"
    
    private init() {}
    
    enum KeychainError: Error {
        case duplicateItem
        case itemNotFound
        case invalidData
        case unhandledError(status: OSStatus)
    }
    
    enum KeychainKey: String {
        case spotifyAccessToken = "spotify_access_token"
        case spotifyRefreshToken = "spotify_refresh_token"
        case spotifyTokenExpiry = "spotify_token_expiry"
        case appleUserToken = "apple_user_token"
        case appleDeveloperToken = "apple_developer_token"
    }
    
    // MARK: - Save Data
    
    func save(_ data: Data, for key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Try to delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    func save(_ string: String, for key: KeychainKey) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        try save(data, for: key)
    }
    
    // MARK: - Retrieve Data
    
    func getData(for key: KeychainKey) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        return data
    }
    
    func getString(for key: KeychainKey) throws -> String {
        let data = try getData(for: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        return string
    }
    
    // MARK: - Delete Data
    
    func delete(key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        // Clear all auth tokens
        let keys: [KeychainKey] = [
            .spotifyAccessToken,
            .spotifyRefreshToken,
            .spotifyTokenExpiry,
            .appleUserToken,
            .appleDeveloperToken
        ]
        
        for key in keys {
            try? delete(key: key)
        }
    }
    
    // MARK: - Convenience Methods
    
    func hasSpotifyAuth() -> Bool {
        return (try? getString(for: .spotifyAccessToken)) != nil
    }
    
    func hasAppleAuth() -> Bool {
        return (try? getString(for: .appleUserToken)) != nil
    }
    
    func getSpotifyTokenExpiry() -> Date? {
        guard let expiryString = try? getString(for: .spotifyTokenExpiry),
              let interval = TimeInterval(expiryString) else {
            return nil
        }
        return Date(timeIntervalSince1970: interval)
    }
    
    func isSpotifyTokenExpired() -> Bool {
        guard let expiry = getSpotifyTokenExpiry() else {
            return true
        }
        return expiry < Date()
    }
}