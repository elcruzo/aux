import Foundation

/// Central configuration for the app
enum AppConfiguration {
    /// API base URL
    static var apiBaseURL: String {
        // Check for environment variable first, then fall back to defaults
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"] {
            return envURL
        }
        
        #if DEBUG
        return "http://127.0.0.1:3000/api"
        #else
        return "https://aux-web.onrender.com/api"  // Update when you have production URL
        #endif
    }
    
    /// Web base URL (for docs, OAuth callbacks, etc)
    static var webBaseURL: String {
        if let envURL = ProcessInfo.processInfo.environment["WEB_BASE_URL"] {
            return envURL
        }
        
        #if DEBUG
        return "http://127.0.0.1:3000"
        #else
        return "https://aux-web.onrender.com"  // Update when you have production URL
        #endif
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
}