import SwiftUI

struct SettingsView: View {
    @StateObject private var authService = ServiceFactory.shared.authService
    @State private var isTestingConnection = false
    @State private var connectionResult: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Connection Test Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("API URL")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(AppConfiguration.apiBaseURL)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                        
                        Button(action: testConnection) {
                            HStack {
                                if isTestingConnection {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wifi")
                                }
                                Text("Test Connection")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(isTestingConnection)
                        
                        if !connectionResult.isEmpty {
                            Text(connectionResult)
                                .font(.system(size: 12))
                                .foregroundStyle(connectionResult.contains("✅") ? .green : .red)
                        }
                    }
                } header: {
                    Text("Connection")
                }
                
                // Authentication Status Section
                Section {
                    // Spotify
                    HStack {
                        PlatformIcon(platform: .spotify, size: 32)
                        Text("Spotify")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        if authService.isSpotifyAuthenticated {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Text("Not connected")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Apple Music
                    HStack {
                        PlatformIcon(platform: .apple, size: 32)
                        Text("Apple Music")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        if authService.isAppleAuthenticated {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Text("Not connected")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Logout button
                    if authService.isSpotifyAuthenticated || authService.isAppleAuthenticated {
                        Button(action: logout) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .foregroundStyle(.red)
                        }
                        .padding(.top, 8)
                    }
                } header: {
                    Text("Accounts")
                }
                
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(AppConfiguration.appVersion) (\(AppConfiguration.buildNumber))")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Environment")
                        Spacer()
                        Text(AppConfiguration.environment)
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com/elcruzo/aux")!) {
                        HStack {
                            Label("GitHub", systemImage: "link")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
                
                // Developer Section
                Section {
                    Link(destination: URL(string: AppConfiguration.apiDocsURL)!) {
                        HStack {
                            Label("API Documentation", systemImage: "doc.text")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: AppConfiguration.apiDocsURL)!) {
                        HStack {
                            Label("API Playground", systemImage: "play.circle")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/elcruzo/aux/issues")!) {
                        HStack {
                            Label("Report an Issue", systemImage: "exclamationmark.bubble")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Developer")
                }
                
                // Resources Section
                Section {
                    Link(destination: URL(string: "https://developer.spotify.com/documentation/web-api")!) {
                        HStack {
                            Label("Spotify Web API", systemImage: "music.note.list")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://developer.apple.com/documentation/applemusicapi")!) {
                        HStack {
                            Label("Apple Music API", systemImage: "applelogo")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Resources")
                }
            }
            .navigationTitle("Settings")
            .task {
                await authService.checkAuthStatus()
            }
        }
    }
    
    private func testConnection() {
        isTestingConnection = true
        connectionResult = ""
        
        Task {
            do {
                // Simple health check
                let url = URL(string: "\(AppConfiguration.apiBaseURL)/health")!
                let (_, response) = try await URLSession.shared.data(from: url)
                
                if let httpResponse = response as? HTTPURLResponse {
                    connectionResult = httpResponse.statusCode == 200 
                        ? "✅ Connected successfully!"
                        : "❌ Server returned: \(httpResponse.statusCode)"
                }
            } catch {
                connectionResult = "❌ Connection failed: \(error.localizedDescription)"
            }
            
            isTestingConnection = false
        }
    }
    
    private func logout() {
        authService.logout()
    }
}

#Preview {
    SettingsView()
}