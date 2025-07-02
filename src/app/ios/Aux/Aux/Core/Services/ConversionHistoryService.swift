import Foundation

/// Service for managing conversion history
@MainActor
final class ConversionHistoryService: ObservableObject {
    static let shared = ConversionHistoryService()
    
    @Published private(set) var conversions: [ConversionRecord] = []
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "aux.conversion.history"
    private let maxHistoryItems = 100
    
    init() {
        loadHistory()
    }
    
    /// Save a conversion to history
    func saveConversion(playlist: Playlist, result: ConversionResult, direction: ConversionDirection) async {
        let record = ConversionRecord(
            id: UUID().uuidString,
            date: Date(),
            playlistName: playlist.name,
            sourcePlaylistId: playlist.id,
            sourcePlatform: direction.source,
            targetPlatform: direction.target,
            totalTracks: result.totalTracks,
            successfulMatches: result.successfulMatches,
            failedMatches: result.failedMatches,
            targetPlaylistId: result.targetPlaylistId,
            targetPlaylistUrl: result.targetPlaylistUrl
        )
        
        conversions.insert(record, at: 0)
        
        // Keep only recent conversions
        if conversions.count > maxHistoryItems {
            conversions = Array(conversions.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    /// Clear all conversion history
    func clearHistory() {
        conversions.removeAll()
        userDefaults.removeObject(forKey: historyKey)
    }
    
    /// Delete a specific conversion record
    func deleteConversion(_ record: ConversionRecord) {
        conversions.removeAll { $0.id == record.id }
        saveHistory()
    }
    
    private func loadHistory() {
        guard let data = userDefaults.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([ConversionRecord].self, from: data) else {
            return
        }
        conversions = decoded
    }
    
    private func saveHistory() {
        guard let encoded = try? JSONEncoder().encode(conversions) else { return }
        userDefaults.set(encoded, forKey: historyKey)
    }
}

/// Represents a conversion record in history
struct ConversionRecord: Codable, Identifiable {
    let id: String
    let date: Date
    let playlistName: String
    let sourcePlaylistId: String
    let sourcePlatform: Track.Platform
    let targetPlatform: Track.Platform
    let totalTracks: Int
    let successfulMatches: Int
    let failedMatches: Int
    let targetPlaylistId: String?
    let targetPlaylistUrl: String?
    
    var successRate: Double {
        guard totalTracks > 0 else { return 0 }
        return Double(successfulMatches) / Double(totalTracks)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}