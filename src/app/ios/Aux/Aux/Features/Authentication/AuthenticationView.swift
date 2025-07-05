import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel: AuthenticationViewModel
    let platform: Track.Platform
    
    init(platform: Track.Platform, coordinator: NavigationCoordinator) {
        self.platform = platform
        self._viewModel = StateObject(wrappedValue: AuthenticationViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Platform icon
            PlatformIcon(platform: platform, size: 80)
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("Connect \(platform.displayName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to access your playlists")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
            } else {
                VStack(spacing: 16) {
                    Button(action: authenticate) {
                        Label("Connect \(platform.displayName)", systemImage: "link")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(platformColor)
                            .foregroundStyle(Color("BackgroundColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    if let error = viewModel.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(Color("ErrorColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        // Auth check removed - now handled centrally in AuxApp
    }
    
    private var platformColor: Color {
        platform == .spotify ? Color("SpotifyGreen") : .primary
    }
    
    private func authenticate() {
        Task {
            switch platform {
            case .spotify:
                await viewModel.authenticateSpotify()
            case .apple:
                await viewModel.authenticateApple()
            }
        }
    }
}

#Preview {
    AuthenticationView(
        platform: .spotify,
        coordinator: NavigationCoordinator()
    )
}