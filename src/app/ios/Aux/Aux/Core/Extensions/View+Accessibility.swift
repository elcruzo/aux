import SwiftUI

extension View {
    /// Adds standard accessibility modifiers for interactive elements
    func accessibleButton(_ label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adds accessibility for platform icons
    func accessiblePlatformIcon(_ platform: Track.Platform) -> some View {
        self.accessibilityLabel("\(platform.displayName) icon")
    }
    
    /// Adds accessibility for status indicators
    func accessibleStatus(_ isConnected: Bool, platform: Track.Platform) -> some View {
        self.accessibilityLabel(
            isConnected 
                ? "Connected to \(platform.displayName)" 
                : "\(platform.displayName) not connected"
        )
    }
}