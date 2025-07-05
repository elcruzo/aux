import SwiftUI

struct ConverterView: View {
    @StateObject private var viewModel: ConverterViewModel
    @FocusState private var isUrlFieldFocused: Bool
    
    init(coordinator: NavigationCoordinator) {
        _viewModel = StateObject(wrappedValue: ConverterViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Logo header
                VStack(spacing: 8) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                    
                    Text("Playlist Converter")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Direction selector
                DirectionSelector(direction: $viewModel.direction)
                    .padding(.horizontal)
                
                // Only show target platform for authentication
                VStack(spacing: 16) {
                    // Source platform (read-only, no auth needed)
                    HStack(spacing: 16) {
                        PlatformIcon(platform: viewModel.sourcePlatform, size: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            Text(viewModel.sourcePlatform.displayName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Text("Public Access")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Target platform (requires auth)
                    PlatformCard(
                        platform: viewModel.targetPlatform,
                        isAuthenticated: viewModel.targetAuthenticated,
                        label: "To",
                        action: viewModel.authenticateTarget
                    )
                }
                .padding(.horizontal)
                
                // Quick Link Convert (Primary flow)
                VStack(spacing: 0) {
                    // Quick convert card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Convert Playlist")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Paste a playlist link to convert")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "link")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.secondary)
                                
                                TextField("Paste playlist URL", text: $viewModel.urlInput)
                                    .textFieldStyle(.plain)
                                    .font(.system(size: 16))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .submitLabel(.go)
                                    .focused($isUrlFieldFocused)
                                    .onSubmit {
                                        if viewModel.isValidURL {
                                            viewModel.convertFromURL()
                                        }
                                    }
                            }
                            
                            if viewModel.isValidURL {
                                Button(action: viewModel.convertFromURL) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Text("Supports Spotify and Apple Music links")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 6) {
                            HStack(spacing: 6) {
                                PlatformIcon(platform: .spotify, size: 16)
                                Text("Spotify")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                            
                            Text("•")
                                .foregroundStyle(.tertiary)
                            
                            HStack(spacing: 6) {
                                PlatformIcon(platform: .apple, size: 16)
                                Text("Apple Music")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.separator), lineWidth: 0.5)
                    )
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.bottom, 20)
        }
        .background(Color("BackgroundColor"))
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isUrlFieldFocused = false
        }
        // Auth check removed - now handled centrally in AuxApp
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
                        PlatformIcon(platform: dir.source, size: 20)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                        
                        PlatformIcon(platform: dir.target, size: 20)
                    }
                    .foregroundStyle(direction == dir ? Color("BackgroundColor") : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        direction == dir ? Color.accentColor : Color.clear
                    )
                }
            }
        }
        .background(Color(.tertiarySystemBackground))
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
            PlatformIcon(platform: platform, size: 48)
            
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
                    .foregroundStyle(Color("SuccessColor"))
            } else {
                Button(action: action) {
                    Text("Connect")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
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