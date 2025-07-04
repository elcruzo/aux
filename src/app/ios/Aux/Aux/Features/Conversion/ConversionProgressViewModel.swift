import Foundation
import Combine

@MainActor
final class ConversionProgressViewModel: ObservableObject {
    let playlist: Playlist
    let direction: ConversionDirection
    
    @Published private(set) var isConverting = false
    @Published private(set) var progress: ConversionProgress?
    @Published private(set) var result: ConversionResult?
    @Published private(set) var error: Error?
    
    private let conversionService: ConversionService
    let coordinator: NavigationCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    init(
        playlist: Playlist,
        direction: ConversionDirection,
        coordinator: NavigationCoordinator,
        conversionService: ConversionService? = nil
    ) {
        self.playlist = playlist
        self.direction = direction
        self.conversionService = conversionService ?? ServiceFactory.shared.conversionService
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        conversionService.$progress
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)
        
        conversionService.$isConverting
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConverting)
    }
    
    func startConversion() async {
        do {
            let result = try await conversionService.convertPlaylist(
                playlist,
                direction: direction
            )
            self.result = result
            
            // Save to history
            await ConversionHistoryService.shared.saveConversion(playlist: playlist, result: result, direction: direction)
            
            coordinator.showConversionResult(result)
        } catch {
            self.error = error
        }
    }
    
    func retry() async {
        error = nil
        await startConversion()
    }
    
    func cancel() {
        // In a real app, we'd implement cancellation
        coordinator.pop()
    }
}