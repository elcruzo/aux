import SwiftUI

struct ConverterView: View {
    @StateObject private var viewModel: ConverterViewModel
    
    init(coordinator: NavigationCoordinator) {
        _viewModel = StateObject(wrappedValue: ConverterViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Simple header
            VStack(spacing: 8) {
                Text("Aux")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("Playlist Converter")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            // Direction selector
            DirectionSelector(direction: $viewModel.direction)
                .padding(.horizontal)
            
            // Platform cards
            VStack(spacing: 16) {
                PlatformCard(
                    platform: viewModel.sourcePlatform,
                    isAuthenticated: viewModel.sourceAuthenticated,
                    label: "From",
                    action: viewModel.authenticateSource
                )
                
                PlatformCard(
                    platform: viewModel.targetPlatform,
                    isAuthenticated: viewModel.targetAuthenticated,
                    label: "To",
                    action: viewModel.authenticateTarget
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Convert button
            if viewModel.canConvert {
                Button(action: viewModel.startConversion) {
                    Text("Select Playlist")
                        .primaryButton()
                }
                .padding(.horizontal)
            }
        }
        .background(Color(.systemBackground))
        .task {
            await viewModel.checkAuthStatus()
        }
    }
}

struct DirectionSelector: View {
    @Binding var direction: ConversionDirection
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([ConversionDirection.spotifyToApple, .appleToSpotify], id: \.self) { dir in
                Button(action: { 
                    withAnimation(.easeInOut(duration: 0.2)) {
                        direction = dir
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: dir.source == .spotify ? "music.note" : "applelogo")
                            .font(.system(size: 14))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                        
                        Image(systemName: dir.target == .spotify ? "music.note" : "applelogo")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(direction == dir ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        direction == dir ? Color.black : Color.clear
                    )
                }
            }
        }
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct PlatformCard: View {
    let platform: Track.Platform
    let isAuthenticated: Bool
    let label: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Platform icon
            Image(systemName: platform == .spotify ? "music.note" : "applelogo")
                .font(.system(size: 24))
                .foregroundStyle(.primary)
                .frame(width: 48, height: 48)
                .background(Color(.systemGray6))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Text(platform.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            if isAuthenticated {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            } else {
                Button(action: action) {
                    Text("Connect")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ConverterView(coordinator: NavigationCoordinator())
}