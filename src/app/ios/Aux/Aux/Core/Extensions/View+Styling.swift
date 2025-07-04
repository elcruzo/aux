import SwiftUI

extension View {
    /// Primary button - uses accent color
    func primaryButton() -> some View {
        self
            .foregroundStyle(Color("BackgroundColor"))
            .font(.system(size: 16, weight: .medium))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    /// Secondary button - adapts to dark/light mode
    func secondaryButton() -> some View {
        self
            .foregroundStyle(.primary)
            .font(.system(size: 16, weight: .medium))
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}