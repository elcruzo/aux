import Foundation
import UIKit

// MARK: - Logging Extension for APIClient
extension APIClient {
    
    /// Logs API requests and responses for debugging
    static func logRequest(method: String, url: URL, body: Data? = nil) {
        print("\n================== API REQUEST ==================")
        print("🌐 \(method) \(url.absoluteString)")
        print("📅 Time: \(Date())")
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("📤 Body: \(bodyString)")
        }
        print("================================================\n")
    }
    
    static func logResponse(url: URL, statusCode: Int, data: Data?, error: Error? = nil) {
        print("\n================== API RESPONSE ==================")
        print("🌐 URL: \(url.absoluteString)")
        print("📅 Time: \(Date())")
        
        if let error = error {
            print("❌ ERROR: \(error.localizedDescription)")
            print("   Details: \(error)")
        } else {
            switch statusCode {
            case 200...299:
                print("✅ Status: \(statusCode) - Success")
            case 400...499:
                print("⚠️ Status: \(statusCode) - Client Error")
            case 500...599:
                print("🔥 Status: \(statusCode) - Server Error")
            default:
                print("❓ Status: \(statusCode) - Unknown")
            }
            
            if let data = data {
                print("📥 Response Size: \(data.count) bytes")
                if let responseString = String(data: data, encoding: .utf8) {
                    let preview = responseString.prefix(500)
                    print("📄 Response Preview: \(preview)\(responseString.count > 500 ? "..." : "")")
                }
            }
        }
        print("================================================\n")
    }
    
    static func logConnectionInfo() {
        print("\n================== CONNECTION INFO ==================")
        print("🔧 API Base URL: \(AppConfiguration.apiBaseURL)")
        print("🔧 Environment: \(AppConfiguration.environment)")
        print("📱 Device: \(UIDevice.current.name)")
        print("📱 iOS Version: \(UIDevice.current.systemVersion)")
        print("====================================================\n")
    }
}