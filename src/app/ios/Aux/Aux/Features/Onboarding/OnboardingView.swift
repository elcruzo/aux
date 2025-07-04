import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with skip button
                HStack {
                    Spacer()
                    
                    if currentPage < 3 {
                        Button(action: { completeOnboarding() }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .frame(height: 60)
                
                // Content
                Group {
                    switch currentPage {
                    case 0:
                        WelcomePage()
                    case 1:
                        HowItWorksPage()
                    case 2:
                        QuickConvertPage()
                    case 3:
                        GetStartedPage(showOnboarding: $showOnboarding)
                    default:
                        WelcomePage()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Bottom navigation
                VStack(spacing: 24) {
                    // Page indicator
                    PageIndicator(currentPage: $currentPage, totalPages: 4)
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: { 
                                withAnimation { currentPage -= 1 }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 14))
                                    Text("Back")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        Button(action: {
                            if currentPage < 3 {
                                withAnimation { currentPage += 1 }
                            } else {
                                completeOnboarding()
                            }
                        }) {
                            HStack {
                                Text(currentPage < 3 ? "Continue" : "Get Started")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            showOnboarding = false
        }
    }
}

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 40) {
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                Text("Welcome to Aux")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("The easiest way to convert playlists between music platforms")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Platform icons preview
            HStack(spacing: 32) {
                PlatformIcon(platform: .spotify, size: 64)
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.secondary)
                PlatformIcon(platform: .apple, size: 64)
            }
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 24)
    }
}

struct HowItWorksPage: View {
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("How It Works")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Choose your conversion method")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                // Method 1 Card
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)
                    
                    VStack(spacing: 8) {
                        Text("Connect Your Accounts")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Sign in to browse and convert all your playlists")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text("OR")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
                
                // Method 2 Card
                VStack(spacing: 20) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                    
                    VStack(spacing: 8) {
                        Text("Quick Convert")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)
                        
                        Text("Just paste a playlist link - no login needed")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 24)
    }
}

struct QuickConvertPage: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)
                
                Text("Quick Convert")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("No login required!\nJust paste a playlist link and convert.")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Example animation
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    PlatformIcon(platform: .spotify, size: 32)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                    PlatformIcon(platform: .apple, size: 32)
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("Works with both platforms")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct GetStartedPage: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color("SuccessColor"))
                    .padding(.top, 40)
                
                VStack(spacing: 12) {
                    Text("Ready to Convert!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Let's convert your first playlist")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Quick tips
            VStack(alignment: .leading, spacing: 16) {
                Label("Connect both platforms for full access", systemImage: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                
                Label("Or paste any playlist link to convert", systemImage: "link")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                
                Label("Check History to see past conversions", systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 24)
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
                .frame(width: 48, height: 48)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PageIndicator: View {
    @Binding var currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}