import SwiftUI

struct ConversionProgressView: View {
    @StateObject private var viewModel: ConversionProgressViewModel
    
    init(
        playlist: Playlist,
        direction: ConversionDirection,
        coordinator: NavigationCoordinator
    ) {
        _viewModel = StateObject(
            wrappedValue: ConversionProgressViewModel(
                playlist: playlist,
                direction: direction,
                coordinator: coordinator
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 32) {
            if let error = viewModel.error {
                // Error state
                errorView(error)
            } else if let progress = viewModel.progress {
                // Progress state
                progressView(progress)
            } else {
                // Initial loading state
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            
            // Playlist info
            VStack(spacing: 8) {
                Text(viewModel.playlist.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(viewModel.direction.source.displayName) → \(viewModel.direction.target.displayName)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Action buttons
            if viewModel.error != nil {
                VStack(spacing: 12) {
                    Button(action: { Task { await viewModel.retry() } }) {
                        Text("Try Again")
                            .primaryButton()
                    }
                    .padding(.horizontal)
                    
                    Button(action: { viewModel.coordinator.popToRoot() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color("ErrorColor"))
                    }
                }
                .padding(.bottom, 32)
            } else if viewModel.isConverting {
                Button(action: { viewModel.coordinator.popToRoot() }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("ErrorColor"))
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Converting")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.startConversion()
        }
    }
    
    @ViewBuilder
    private func progressView(_ progress: ConversionProgress) -> some View {
        VStack(spacing: 24) {
            // Icon with progress
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemBackground), lineWidth: 3)
                    .frame(width: 80, height: 80)
                
                if progress.total > 0 {
                    Circle()
                        .trim(from: 0, to: Double(progress.current) / Double(progress.total))
                        .stroke(progressColor(for: progress.stage), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: progress.current)
                }
                
                Image(systemName: stageIcon(for: progress.stage))
                    .font(.system(size: 32))
                    .foregroundStyle(progressColor(for: progress.stage))
            }
            
            // Status text
            VStack(spacing: 8) {
                Text(progress.message)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                if progress.total > 0 && progress.stage != .complete {
                    Text("\(progress.current) of \(progress.total)")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("ErrorColor"))
            
            VStack(spacing: 8) {
                Text("Conversion Failed")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(error.localizedDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    private func stageIcon(for stage: ConversionProgress.Stage) -> String {
        switch stage {
        case .fetching:
            return "square.and.arrow.down"
        case .matching:
            return "link"
        case .creating:
            return "plus.circle"
        case .adding:
            return "square.and.arrow.up"
        case .complete:
            return "checkmark.circle"
        }
    }
    
    private func progressColor(for stage: ConversionProgress.Stage) -> Color {
        switch stage {
        case .complete:
            return Color("SuccessColor")
        default:
            return .primary
        }
    }
}

#Preview {
    NavigationView {
        ConversionProgressView(
            playlist: Playlist(
                id: "1",
                name: "Test Playlist",
                description: nil,
                imageUrl: nil,
                trackCount: 50,
                owner: "User",
                platform: .spotify
            ),
            direction: .spotifyToApple,
            coordinator: NavigationCoordinator()
        )
    }
}