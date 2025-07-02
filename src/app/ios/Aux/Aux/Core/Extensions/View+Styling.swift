import SwiftUI

extension View {
    /// Clean card with subtle shadow
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    /// Minimal border
    func subtleBorder() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
    
    /// Primary button - clean and modern
    func primaryButton() -> some View {
        self
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .medium))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// Secondary button
    func secondaryButton() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 16, weight: .medium))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// Tertiary button - text only
    func tertiaryButton() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 16, weight: .medium))
    }
}