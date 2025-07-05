import Foundation

/// Central configuration for the app
enum AppConfiguration {
    /// API base URL
    static var apiBaseURL: String {
        // Read host from Info.plist and construct full URL
        if let host = Bundle.main.infoDictionary?["API_HOST"] as? String {
            return "https://\(host)/api"
        }
        
        // Fallback to production
        return "https://aux-50dr.onrender.com/api"
    }
    
    /// Web base URL (for docs, OAuth callbacks, etc)
    static var webBaseURL: String {
        // Read host from Info.plist and construct full URL
        if let host = Bundle.main.infoDictionary?["WEB_HOST"] as? String {
            return "https://\(host)"
        }
        
        // Fallback to production
        return "https://aux-50dr.onrender.com"
    }
    
    /// API documentation URL
    static var apiDocsURL: String {
        return "\(webBaseURL)/api-docs"
    }
    
    /// App URL scheme for OAuth callbacks
    static let appURLScheme = "aux"
    
    /// Bundle identifier
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.aux.app"
    
    /// App version
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    /// Build number
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    /// Is running in debug mode
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    /// Current environment
    static var environment: String {
        #if DEBUG
        return "DEBUG"
        #else
        return "RELEASE"
        #endif
    }
}