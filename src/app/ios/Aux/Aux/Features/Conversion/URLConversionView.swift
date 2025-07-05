import SwiftUI

struct URLConversionView: View {
    let url: String
    let direction: ConversionDirection
    @StateObject private var viewModel: URLConversionViewModel
    
    init(url: String, direction: ConversionDirection, coordinator: NavigationCoordinator) {
        self.url = url
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: URLConversionViewModel(
                url: url,
                direction: direction,
                coordinator: coordinator
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if viewModel.isLoading {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.5)
                    
                    Text(viewModel.statusMessage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else if let error = viewModel.error {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(Color("ErrorColor"))
                    
                    Text("Conversion Failed")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Text(error.localizedDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task { await viewModel.startConversion() }
                    }) {
                        Text("Try Again")
                            .secondaryButton()
                    }
                    .padding(.horizontal)
                }
                Spacer()
            } else if let playlist = viewModel.extractedPlaylist {
                // Show playlist preview
                VStack(spacing: 20) {
                    // Playlist info
                    HStack(spacing: 16) {
                        if let imageUrl = playlist.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.tertiarySystemBackground))
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(playlist.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            
                            Text("by \(playlist.owner)")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Text("\(playlist.trackCount) tracks")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Direction indicator
                    HStack(spacing: 12) {
                        PlatformIcon(platform: direction.source, size: 32)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.secondary)
                        PlatformIcon(platform: direction.target, size: 32)
                    }
                    
                    Spacer()
                    
                    // Convert button
                    Button(action: {
                        Task { await viewModel.convertPlaylist() }
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Convert to \(direction.target.displayName)")
                        }
                        .primaryButton()
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .navigationTitle("Convert Playlist")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("BackgroundColor"))
        .task {
            await viewModel.startConversion()
        }
    }
}

#Preview {
    NavigationView {
        URLConversionView(
            url: "https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M",
            direction: .spotifyToApple,
            coordinator: NavigationCoordinator()
        )
    }
}