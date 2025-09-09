//
//  AppStoreConfiguration.swift
//  Aux
//
//  Configuration for App Store deployment and distribution
//

import Foundation
import StoreKit

struct AppStoreConfiguration {
    
    // MARK: - App Store Connect Configuration
    static let appID = "6451234567" // Replace with actual App Store ID
    static let bundleIdentifier = "com.elcruzo.aux"
    static let appStoreURL = "https://apps.apple.com/app/aux-playlist-converter/id6451234567"
    static let developerName = "Ayomide Adekoya"
    static let supportEmail = "ayomideadekoya266@gmail.com"
    static let privacyPolicyURL = "https://aux-50dr.onrender.com/privacy"
    static let termsOfServiceURL = "https://aux-50dr.onrender.com/terms"
    
    // MARK: - App Store Review Configuration
    static let minVersionForReview = "1.0.0"
    static let reviewPromptThreshold = 5 // Number of successful conversions before prompting
    
    // MARK: - Feature Flags for App Store
    static let enableAnalytics = true
    static let enableCrashReporting = false // Disable for privacy
    static let enableRemoteConfig = false
    static let enableDeepLinking = true
    static let enableShareExtension = true
    static let enableWidgets = true
    static let enableSiriShortcuts = true
    
    // MARK: - Privacy Configuration
    static let dataCollectionPractices: [String: Any] = [
        "dataTypes": [
            [
                "category": "Contact Info",
                "types": [],
                "purposes": [],
                "linked": false,
                "tracking": false
            ],
            [
                "category": "User Content",
                "types": ["Audio Data"],
                "purposes": ["App Functionality"],
                "linked": false,
                "tracking": false
            ],
            [
                "category": "Usage Data",
                "types": ["Product Interaction"],
                "purposes": ["Analytics", "App Functionality"],
                "linked": false,
                "tracking": false
            ]
        ],
        "privacyChoices": true,
        "dataRetention": "User controlled",
        "dataDeletion": "Available on request"
    ]
}

// MARK: - App Store Review Helper
class AppStoreReviewHelper {
    static let shared = AppStoreReviewHelper()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    /// Request App Store review if conditions are met
    func requestReviewIfAppropriate() {
        let conversionsCount = userDefaults.integer(forKey: "successful_conversions_count")
        let hasRequestedReview = userDefaults.bool(forKey: "has_requested_review")
        let lastRequestDate = userDefaults.object(forKey: "last_review_request_date") as? Date
        
        // Don't request if already requested recently
        if let lastDate = lastRequestDate,
           Date().timeIntervalSince(lastDate) < 60 * 60 * 24 * 90 { // 90 days
            return
        }
        
        // Request review after threshold conversions
        if conversionsCount >= AppStoreConfiguration.reviewPromptThreshold && !hasRequestedReview {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    
                    self.userDefaults.set(true, forKey: "has_requested_review")
                    self.userDefaults.set(Date(), forKey: "last_review_request_date")
                }
            }
        }
    }
    
    /// Track successful conversion for review prompting
    func trackSuccessfulConversion() {
        let count = userDefaults.integer(forKey: "successful_conversions_count") + 1
        userDefaults.set(count, forKey: "successful_conversions_count")
        
        // Request review if threshold reached
        if count == AppStoreConfiguration.reviewPromptThreshold {
            requestReviewIfAppropriate()
        }
    }
    
    /// Open App Store page for rating
    func openAppStore() {
        guard let url = URL(string: AppStoreConfiguration.appStoreURL) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - App Store Metadata Helper
struct AppStoreMetadata {
    
    // App Store description (keep under 4000 characters)
    static let description = """
    Convert playlists between Spotify and Apple Music with just a tap! Aux makes it effortless to share and enjoy music across platforms.
    
    🎵 SEAMLESS CONVERSION
    • Share any playlist link to Aux for instant conversion
    • Smart matching finds the exact same songs on your platform
    • Works with public playlists, personal playlists, and collaborative playlists
    • Universal Share Extension works from any app
    
    ✨ SMART FEATURES
    • Advanced algorithm ensures perfect song matching
    • Conversion history to track all your converted playlists
    • Beautiful, native iOS interface
    • Privacy-first design - no data stored or tracked
    
    🚀 QUICK & EASY
    1. See a playlist link from any platform? Tap Share → "Convert with Aux"
    2. Or open Aux and paste any Spotify/Apple Music playlist URL
    3. Your converted playlist appears instantly in your music library
    
    🔐 PRIVACY FOCUSED
    • Secure authentication with official APIs
    • No personal data stored on our servers
    • No tracking or analytics
    • Your music stays private
    
    Perfect for music lovers who want to share playlists with friends regardless of their music platform preference. Never miss out on great music again!
    
    Works with both Spotify and Apple Music. Requires active subscription to your chosen music service.
    """
    
    // App Store keywords (max 100 characters)
    static let keywords = "playlist,convert,spotify,apple music,music,share,transfer,convert playlist"
    
    // What's New text for updates
    static let whatsNew = """
    🎉 NEW FEATURES:
    • Widget support for quick playlist conversions
    • Siri Shortcuts: "Hey Siri, convert this playlist"
    • Analytics dashboard to track your conversion stats
    • Advanced settings for power users
    
    🐛 IMPROVEMENTS:
    • Faster playlist matching algorithm
    • Enhanced error handling and recovery
    • Better support for large playlists
    • UI polish and accessibility improvements
    
    Thank you for using Aux! Keep the music flowing. 🎵
    """
    
    // App Store categories
    static let primaryCategory = "Music"
    static let secondaryCategory = "Utilities"
    
    // Content rating
    static let contentRating = "4+" // Clean content, suitable for all ages
    
    // Supported devices
    static let supportedDevices = [
        "iPhone (iOS 16.0+)",
        "iPad (iPadOS 16.0+)",
        "Apple Watch (watchOS 9.0+) - Companion app",
        "Mac (macOS 13.0+) - Designed for iPad"
    ]
    
    // App Store review guidelines compliance notes
    static let complianceNotes = """
    COMPLIANCE CHECKLIST:
    
    ✅ App Store Review Guidelines:
    - No misleading functionality
    - Proper use of platform APIs
    - Clear privacy policy
    - No promotional content or advertising
    - Family-friendly content
    
    ✅ Technical Requirements:
    - 64-bit support
    - iOS 16.0+ minimum deployment target
    - Proper use of iOS frameworks
    - No private API usage
    - Follows Apple's Design Guidelines
    
    ✅ Music Platform Requirements:
    - Spotify: Uses official Web API only
    - Apple Music: Uses MusicKit and Apple Music API
    - No downloading or circumventing DRM
    - Respects platform rate limits
    
    ✅ Privacy & Security:
    - No tracking without consent
    - Secure token storage in Keychain
    - HTTPS-only communications
    - Privacy policy clearly states data usage
    
    ✅ Intellectual Property:
    - No copyrighted assets used without permission
    - Original app icon and branding
    - Proper attribution for open source components
    - No trademark violations
    """
}

// MARK: - Distribution Configuration
struct DistributionConfiguration {
    
    // Development Team
    static let developmentTeam = "ABC1234567" // Replace with actual Team ID
    static let codeSignIdentity = "Apple Development"
    static let provisioningProfile = "match Development com.elcruzo.aux"
    
    // Production settings
    static let productionTeam = "ABC1234567"
    static let productionCodeSign = "Apple Distribution"
    static let productionProfile = "match AppStore com.elcruzo.aux"
    
    // App Store Connect
    static let appStoreConnectKey = "ABC123DEF4"
    static let appStoreConnectKeyFile = "AuthKey_ABC123DEF4.p8"
    static let appStoreConnectIssuer = "12345678-1234-1234-1234-123456789012"
    
    // Build configuration
    static let archiveScheme = "Aux"
    static let exportMethod = "app-store"
    static let uploadSymbols = true
    static let stripBitcode = true
    
    // TestFlight configuration
    static let betaGroups = ["Internal Testers", "External Testers"]
    static let releaseNotes = AppStoreMetadata.whatsNew
    static let skipWaiting = false
    static let distributionBundleIdentifier = "com.elcruzo.aux"
    
    // Version management
    static let automaticVersion = true
    static let buildNumberFromGit = true
    static let versionBumpType = "patch" // patch, minor, major
}

// MARK: - Launch Configuration
extension AppStoreConfiguration {
    
    /// Configure app for App Store submission
    static func configureForAppStore() {
        #if RELEASE
        // Disable debug features
        UserDefaults.standard.set(false, forKey: "enable_debug_menu")
        UserDefaults.standard.set(false, forKey: "enable_api_logging")
        UserDefaults.standard.set(false, forKey: "enable_mock_data")
        
        // Enable production features
        UserDefaults.standard.set(enableAnalytics, forKey: "enable_analytics")
        UserDefaults.standard.set(enableDeepLinking, forKey: "enable_deep_linking")
        UserDefaults.standard.set(enableShareExtension, forKey: "enable_share_extension")
        
        print("🏪 App configured for App Store release")
        #endif
    }
    
    /// Validate app store readiness
    static func validateAppStoreReadiness() -> [String] {
        var issues: [String] = []
        
        // Check required URLs
        if URL(string: privacyPolicyURL) == nil {
            issues.append("Invalid privacy policy URL")
        }
        
        if URL(string: termsOfServiceURL) == nil {
            issues.append("Invalid terms of service URL")
        }
        
        // Check bundle configuration
        if Bundle.main.bundleIdentifier != bundleIdentifier {
            issues.append("Bundle identifier mismatch")
        }
        
        // Check version format
        if Bundle.main.infoDictionary?["CFBundleShortVersionString"] == nil {
            issues.append("Missing version string")
        }
        
        // Check required permissions
        let requiredKeys = [
            "NSAppleMusicUsageDescription",
            "NSInternetUsageDescription"
        ]
        
        for key in requiredKeys {
            if Bundle.main.object(forInfoDictionaryKey: key) == nil {
                issues.append("Missing required key: \(key)")
            }
        }
        
        return issues
    }
}