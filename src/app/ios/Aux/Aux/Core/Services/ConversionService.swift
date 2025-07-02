import Foundation
import Combine

/// Service responsible for playlist conversion operations
@MainActor
final class ConversionService: ObservableObject {
    @Published private(set) var isConverting = false
    @Published private(set) var progress: ConversionProgress?
    @Published private(set) var lastResult: ConversionResult?
    @Published private(set) var error: Error?
    
    private let apiClient: APIClient
    private let playlistService: PlaylistService
    
    init(apiClient: APIClient, playlistService: PlaylistService) {
        self.apiClient = apiClient
        self.playlistService = playlistService
    }
    
    /// Convert a playlist from one platform to another with detailed progress
    func convertPlaylist(_ playlist: Playlist, direction: ConversionDirection) async throws -> ConversionResult {
        isConverting = true
        error = nil
        
        do {
            // Stage 1: Fetch tracks from source playlist
            progress = ConversionProgress(
                stage: .fetching,
                current: 0,
                total: playlist.trackCount,
                message: "Fetching tracks from \(playlist.name)..."
            )
            
            let tracks = try await playlistService.fetchTracks(for: playlist)
            
            progress = ConversionProgress(
                stage: .fetching,
                current: tracks.count,
                total: playlist.trackCount,
                message: "Fetched \(tracks.count) tracks"
            )
            
            // Small delay to show progress
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // Stage 2: Match tracks on target platform
            progress = ConversionProgress(
                stage: .matching,
                current: 0,
                total: tracks.count,
                message: "Matching tracks on \(direction.target.displayName)..."
            )
            
            // Simulate progress during matching (in real app, this would be from API)
            for i in stride(from: 0, to: tracks.count, by: max(1, tracks.count / 5)) {
                progress = ConversionProgress(
                    stage: .matching,
                    current: min(i, tracks.count),
                    total: tracks.count,
                    message: "Matching track \(min(i + 1, tracks.count)) of \(tracks.count)"
                )
                try await Task.sleep(nanoseconds: 200_000_000)
            }
            
            // Stage 3: Create playlist
            progress = ConversionProgress(
                stage: .creating,
                current: 0,
                total: 1,
                message: "Creating playlist on \(direction.target.displayName)..."
            )
            
            // Call the actual conversion API
            let result = try await apiClient.convertPlaylist(
                playlistId: playlist.id,
                playlistName: playlist.name,
                direction: direction
            )
            
            // Stage 4: Show completion
            progress = ConversionProgress(
                stage: .complete,
                current: result.totalTracks,
                total: result.totalTracks,
                message: "Successfully converted \(result.successfulMatches) of \(result.totalTracks) tracks!"
            )
            
            lastResult = result
            isConverting = false
            
            // Save to history
            await ConversionHistoryService.shared.saveConversion(
                playlist: playlist,
                result: result,
                direction: direction
            )
            
            return result
        } catch {
            self.error = error
            isConverting = false
            
            progress = ConversionProgress(
                stage: .complete,
                current: 0,
                total: 0,
                message: "Conversion failed: \(error.localizedDescription)"
            )
            
            throw error
        }
    }
    
    /// Reset the service state
    func reset() {
        isConverting = false
        progress = nil
        lastResult = nil
        error = nil
    }
}