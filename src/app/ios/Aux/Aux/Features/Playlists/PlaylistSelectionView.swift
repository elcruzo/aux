import SwiftUI

struct PlaylistSelectionView: View {
    @StateObject private var viewModel: PlaylistSelectionViewModel
    
    init(direction: ConversionDirection, coordinator: NavigationCoordinator) {
        _viewModel = StateObject(
            wrappedValue: PlaylistSelectionViewModel(
                direction: direction,
                coordinator: coordinator
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search playlists", text: $viewModel.searchText)
                    .font(.system(size: 16))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
            if let error = viewModel.error {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(Color("ErrorColor"))
                    
                    Text("Failed to load playlists")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.primary)
                    
                    Text(error.localizedDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task { await viewModel.loadPlaylists() }
                    }) {
                        Text("Try Again")
                            .secondaryButton()
                    }
                    .padding(.horizontal)
                }
                Spacer()
            } else if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            } else if viewModel.filteredPlaylists.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No playlists found")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.filteredPlaylists) { playlist in
                            PlaylistRow(
                                playlist: playlist,
                                onSelect: { viewModel.selectPlaylist(playlist) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Select Playlist")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("BackgroundColor"))
        .task {
            await viewModel.loadPlaylists()
        }
    }
}

struct PlaylistRow: View {
    let playlist: Playlist
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Playlist image
                if let imageUrl = playlist.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.tertiarySystemBackground))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.5)
                            )
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "music.note.list")
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(playlist.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Text("\(playlist.trackCount) tracks")
                        Text("•")
                        Text(playlist.owner)
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        PlaylistSelectionView(
            direction: .spotifyToApple,
            coordinator: NavigationCoordinator()
        )
    }
}