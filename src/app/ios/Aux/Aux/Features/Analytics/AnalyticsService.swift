//
//  AnalyticsService.swift
//  Aux
//
//  Privacy-focused analytics for conversion insights
//

import Foundation
import UIKit

protocol AnalyticsServiceProtocol {
    func trackConversion(from: String, to: String, playlistSize: Int, duration: TimeInterval)
    func trackConversionError(error: String, context: String)
    func trackAppLaunch()
    func trackAuthenticationEvent(platform: String, success: Bool)
    func getConversionStats() async -> ConversionStats
    func getPopularConversions() async -> [ConversionFlowStats]
}

struct ConversionStats {
    let totalConversions: Int
    let avgConversionTime: TimeInterval
    let successRate: Double
    let platformBreakdown: [String: Int]
    let avgPlaylistSize: Int
    let weeklyGrowth: Double
}

struct ConversionFlowStats {
    let fromPlatform: String
    let toPlatform: String
    let count: Int
    let percentage: Double
}

class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private let userDefaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "com.aux.analytics", qos: .utility)
    
    private init() {
        // Initialize analytics on first launch
        if !userDefaults.bool(forKey: "analytics_initialized") {
            initializeAnalytics()
        }
    }
    
    // MARK: - Public Interface
    
    func trackConversion(from: String, to: String, playlistSize: Int, duration: TimeInterval) {
        queue.async {
            let event = ConversionEvent(
                id: UUID().uuidString,
                fromPlatform: from,
                toPlatform: to,
                playlistSize: playlistSize,
                duration: duration,
                timestamp: Date()
            )
            
            self.saveConversionEvent(event)
            self.updateConversionStats(event)
        }
    }
    
    func trackConversionError(error: String, context: String) {
        queue.async {
            let errorEvent = ErrorEvent(
                id: UUID().uuidString,
                error: error,
                context: context,
                timestamp: Date()
            )
            
            self.saveErrorEvent(errorEvent)
        }
    }
    
    func trackAppLaunch() {
        queue.async {
            let launchCount = self.userDefaults.integer(forKey: "app_launch_count") + 1
            self.userDefaults.set(launchCount, forKey: "app_launch_count")
            self.userDefaults.set(Date(), forKey: "last_launch_date")
            
            // Track launch event
            let event = LaunchEvent(
                id: UUID().uuidString,
                launchCount: launchCount,
                timestamp: Date(),
                appVersion: AppConfiguration.appVersion
            )
            
            self.saveLaunchEvent(event)
        }
    }
    
    func trackAuthenticationEvent(platform: String, success: Bool) {
        queue.async {
            let event = AuthEvent(
                id: UUID().uuidString,
                platform: platform,
                success: success,
                timestamp: Date()
            )
            
            self.saveAuthEvent(event)
        }
    }
    
    func getConversionStats() async -> ConversionStats {
        return await withCheckedContinuation { continuation in
            queue.async {
                let stats = self.calculateConversionStats()
                continuation.resume(returning: stats)
            }
        }
    }
    
    func getPopularConversions() async -> [ConversionFlowStats] {
        return await withCheckedContinuation { continuation in
            queue.async {
                let directions = self.calculatePopularConversions()
                continuation.resume(returning: directions)
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private func initializeAnalytics() {
        userDefaults.set(Date(), forKey: "analytics_install_date")
        userDefaults.set(AppConfiguration.appVersion, forKey: "analytics_install_version")
        userDefaults.set(true, forKey: "analytics_initialized")
        
        // Create initial empty data structures
        saveConversionEvents([])
        saveErrorEvents([])
        saveLaunchEvents([])
        saveAuthEvents([])
    }
    
    private func saveConversionEvent(_ event: ConversionEvent) {
        var events = loadConversionEvents()
        events.append(event)
        
        // Keep only last 1000 events
        if events.count > 1000 {
            events = Array(events.suffix(1000))
        }
        
        saveConversionEvents(events)
    }
    
    private func saveErrorEvent(_ event: ErrorEvent) {
        var events = loadErrorEvents()
        events.append(event)
        
        // Keep only last 500 error events
        if events.count > 500 {
            events = Array(events.suffix(500))
        }
        
        saveErrorEvents(events)
    }
    
    private func saveLaunchEvent(_ event: LaunchEvent) {
        var events = loadLaunchEvents()
        events.append(event)
        
        // Keep only last 100 launch events
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        saveLaunchEvents(events)
    }
    
    private func saveAuthEvent(_ event: AuthEvent) {
        var events = loadAuthEvents()
        events.append(event)
        
        // Keep only last 200 auth events
        if events.count > 200 {
            events = Array(events.suffix(200))
        }
        
        saveAuthEvents(events)
    }
    
    private func updateConversionStats(_ event: ConversionEvent) {
        // Update quick access stats
        let totalConversions = userDefaults.integer(forKey: "total_conversions") + 1
        userDefaults.set(totalConversions, forKey: "total_conversions")
        
        let totalDuration = userDefaults.double(forKey: "total_duration") + event.duration
        userDefaults.set(totalDuration, forKey: "total_duration")
        
        // Update platform counts
        let fromKey = "conversions_from_\(event.fromPlatform.lowercased())"
        let toKey = "conversions_to_\(event.toPlatform.lowercased())"
        
        userDefaults.set(userDefaults.integer(forKey: fromKey) + 1, forKey: fromKey)
        userDefaults.set(userDefaults.integer(forKey: toKey) + 1, forKey: toKey)
    }
    
    private func calculateConversionStats() -> ConversionStats {
        let events = loadConversionEvents()
        let totalConversions = events.count
        
        guard totalConversions > 0 else {
            return ConversionStats(
                totalConversions: 0,
                avgConversionTime: 0,
                successRate: 0,
                platformBreakdown: [:],
                avgPlaylistSize: 0,
                weeklyGrowth: 0
            )
        }
        
        let avgDuration = events.reduce(0) { $0 + $1.duration } / Double(totalConversions)
        let avgPlaylistSize = Int(events.reduce(0) { $0 + $1.playlistSize } / events.count)
        
        // Calculate platform breakdown
        var platformBreakdown: [String: Int] = [:]
        for event in events {
            let direction = "\(event.fromPlatform) → \(event.toPlatform)"
            platformBreakdown[direction] = (platformBreakdown[direction] ?? 0) + 1
        }
        
        // Calculate weekly growth
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentEvents = events.filter { $0.timestamp >= oneWeekAgo }
        let weeklyGrowth = events.count > recentEvents.count ? 
            (Double(recentEvents.count) / Double(events.count - recentEvents.count)) * 100 : 0
        
        // Success rate (assume 100% for successful conversions tracked)
        let successRate = 1.0
        
        return ConversionStats(
            totalConversions: totalConversions,
            avgConversionTime: avgDuration,
            successRate: successRate,
            platformBreakdown: platformBreakdown,
            avgPlaylistSize: avgPlaylistSize,
            weeklyGrowth: weeklyGrowth
        )
    }
    
    private func calculatePopularConversions() -> [ConversionDirection] {
        let events = loadConversionEvents()
        let totalConversions = events.count
        
        guard totalConversions > 0 else { return [] }
        
        var directionCounts: [String: Int] = [:]
        
        for event in events {
            let key = "\(event.fromPlatform)|\(event.toPlatform)"
            directionCounts[key] = (directionCounts[key] ?? 0) + 1
        }
        
        return directionCounts.map { key, count in
            let components = key.components(separatedBy: "|")
            return ConversionFlowStats(
                fromPlatform: components[0],
                toPlatform: components[1],
                count: count,
                percentage: Double(count) / Double(totalConversions) * 100
            )
        }.sorted { $0.count > $1.count }
    }
    
    // MARK: - Data Persistence
    
    private func loadConversionEvents() -> [ConversionEvent] {
        guard let data = userDefaults.data(forKey: "conversion_events"),
              let events = try? JSONDecoder().decode([ConversionEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveConversionEvents(_ events: [ConversionEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            userDefaults.set(data, forKey: "conversion_events")
        }
    }
    
    private func loadErrorEvents() -> [ErrorEvent] {
        guard let data = userDefaults.data(forKey: "error_events"),
              let events = try? JSONDecoder().decode([ErrorEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveErrorEvents(_ events: [ErrorEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            userDefaults.set(data, forKey: "error_events")
        }
    }
    
    private func loadLaunchEvents() -> [LaunchEvent] {
        guard let data = userDefaults.data(forKey: "launch_events"),
              let events = try? JSONDecoder().decode([LaunchEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveLaunchEvents(_ events: [LaunchEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            userDefaults.set(data, forKey: "launch_events")
        }
    }
    
    private func loadAuthEvents() -> [AuthEvent] {
        guard let data = userDefaults.data(forKey: "auth_events"),
              let events = try? JSONDecoder().decode([AuthEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    private func saveAuthEvents(_ events: [AuthEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            userDefaults.set(data, forKey: "auth_events")
        }
    }
}

// MARK: - Event Models

struct ConversionEvent: Codable {
    let id: String
    let fromPlatform: String
    let toPlatform: String
    let playlistSize: Int
    let duration: TimeInterval
    let timestamp: Date
}

struct ErrorEvent: Codable {
    let id: String
    let error: String
    let context: String
    let timestamp: Date
}

struct LaunchEvent: Codable {
    let id: String
    let launchCount: Int
    let timestamp: Date
    let appVersion: String
}

struct AuthEvent: Codable {
    let id: String
    let platform: String
    let success: Bool
    let timestamp: Date
}

// MARK: - Analytics Dashboard (for Settings)
extension AnalyticsService {
    
    func exportAnalyticsData() -> String {
        let stats = calculateConversionStats()
        let popularDirections = calculatePopularConversions()
        
        var export = """
        Aux Analytics Export
        Generated: \(Date())
        
        CONVERSION STATISTICS
        Total Conversions: \(stats.totalConversions)
        Average Conversion Time: \(String(format: "%.1f", stats.avgConversionTime))s
        Average Playlist Size: \(stats.avgPlaylistSize) tracks
        Success Rate: \(String(format: "%.1f", stats.successRate * 100))%
        Weekly Growth: \(String(format: "%.1f", stats.weeklyGrowth))%
        
        POPULAR CONVERSION DIRECTIONS
        """
        
        for direction in popularDirections.prefix(5) {
            export += "\n\(direction.fromPlatform) → \(direction.toPlatform): \(direction.count) (\(String(format: "%.1f", direction.percentage))%)"
        }
        
        return export
    }
    
    func clearAnalyticsData() {
        queue.async {
            let keys = [
                "conversion_events", "error_events", "launch_events", "auth_events",
                "total_conversions", "total_duration", "app_launch_count"
            ]
            
            for key in keys {
                self.userDefaults.removeObject(forKey: key)
            }
            
            // Remove platform-specific keys
            let platforms = ["spotify", "apple"]
            for platform in platforms {
                self.userDefaults.removeObject(forKey: "conversions_from_\(platform)")
                self.userDefaults.removeObject(forKey: "conversions_to_\(platform)")
            }
            
            self.initializeAnalytics()
        }
    }
}