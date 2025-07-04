import SwiftUI

struct ConverterView: View {
    @StateObject private var viewModel: ConverterViewModel
    @FocusState private var isUrlFieldFocused: Bool
    
    init(coordinator: NavigationCoordinator) {
        _viewModel = StateObject(wrappedValue: ConverterViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
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
            
            // Browse button - shows when authenticated
            if viewModel.canSelectPlaylist {
                Button(action: viewModel.startConversion) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 16))
                        Text("Browse My Playlists")
                            .font(.system(size: 16, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Alternative: Quick Link Convert
            VStack(spacing: 0) {
                // Divider with "or"
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                    
                    Text("or")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                // Quick convert card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.accentColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Convert")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Paste a link, skip the login")
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
                                .id("urlField")
                            
                            if !viewModel.urlInput.isEmpty {
                                Button(action: { viewModel.urlInput = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !viewModel.urlInput.isEmpty && viewModel.isValidURL {
                            Button(action: viewModel.convertFromURL) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color.accentColor)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    // Supported platforms hint
                    HStack(spacing: 16) {
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
        .onChange(of: isUrlFieldFocused) { oldValue, newValue in
            if newValue {
                withAnimation {
                    proxy.scrollTo("urlField", anchor: .center)
                }
            }
        }
        }
        .background(Color("BackgroundColor"))
        .ignoresSafeArea(.keyboard)
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