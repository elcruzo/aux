import SwiftUI

struct PlatformIcon: View {
    let platform: Track.Platform
    let size: CGFloat
    
    var body: some View {
        Image(platform == .spotify ? "SpotifyLogo" : "AppleMusicLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        PlatformIcon(platform: .spotify, size: 48)
        PlatformIcon(platform: .apple, size: 48)
    }
    .padding()
}