import SwiftUI

struct ConversionResultView: View {
    let result: ConversionResult
    let coordinator: NavigationCoordinator
    
    private var successRate: Double {
        guard result.totalTracks > 0 else { return 0 }
        return Double(result.successfulMatches) / Double(result.totalTracks)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success indicator
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("SuccessColor"))
                        .symbolEffect(.bounce)
                    
                    Text("Conversion Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(result.playlistName)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                // Statistics
                VStack(spacing: 20) {
                    StatRow(
                        title: "Total Tracks",
                        value: "\(result.totalTracks)",
                        color: .primary
                    )
                    
                    StatRow(
                        title: "Successful Matches",
                        value: "\(result.successfulMatches)",
                        color: Color("SuccessColor")
                    )
                    
                    if result.failedMatches > 0 {
                        StatRow(
                            title: "Failed Matches",
                            value: "\(result.failedMatches)",
                            color: Color("ErrorColor")
                        )
                    }
                    
                    // Success rate
                    VStack(spacing: 8) {
                        Text("Success Rate")
                            .font(.headline)
                        
                        ZStack {
                            Circle()
                                .stroke(Color(.systemFill), lineWidth: 8)
                            
                            Circle()
                                .trim(from: 0, to: successRate)
                                .stroke(successRateColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.8), value: successRate)
                        }
                        .frame(width: 120, height: 120)
                        .overlay {
                            Text("\(Int(successRate * 100))%")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
                
                // Match breakdown
                if !result.matches.isEmpty {
                    MatchBreakdownView(matches: result.matches)
                        .padding(.horizontal)
                }
                
                // Actions
                VStack(spacing: 16) {
                    Button(action: { coordinator.popToRoot() }) {
                        Label("Convert Another Playlist", systemImage: "arrow.2.circlepath")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("SuccessColor"))
                            .foregroundStyle(Color("BackgroundColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    Button("Done") {
                        coordinator.popToRoot()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    private var successRateColor: Color {
        if successRate >= 0.9 {
            return Color("SuccessColor")
        } else if successRate >= 0.7 {
            return Color("WarningColor")
        } else {
            return Color("MediumWarningColor")
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MatchBreakdownView: View {
    let matches: [TrackMatch]
    @State private var isExpanded = false
    
    private var matchesByConfidence: [TrackMatch.Confidence: [TrackMatch]] {
        Dictionary(grouping: matches, by: { $0.confidence })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text("Match Details")
                        .font(.headline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(TrackMatch.Confidence.allCases, id: \.self) { confidence in
                        if let matches = matchesByConfidence[confidence], !matches.isEmpty {
                            HStack {
                                Circle()
                                    .fill(confidenceColor(confidence))
                                    .frame(width: 12, height: 12)
                                
                                Text("\(confidence.rawValue.capitalized): \(matches.count)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func confidenceColor(_ confidence: TrackMatch.Confidence) -> Color {
        switch confidence {
        case .high: return Color("SuccessColor")
        case .medium: return Color("WarningColor")
        case .low: return Color("MediumWarningColor")
        case .none: return Color("ErrorColor")
        }
    }
}

// Extension to make Confidence CaseIterable for SwiftUI
extension TrackMatch.Confidence: CaseIterable {
    public static var allCases: [TrackMatch.Confidence] = [.high, .medium, .low, .none]
}

#Preview {
    NavigationStack {
        ConversionResultView(
            result: ConversionResult(
                playlistId: "1",
                playlistName: "My Awesome Playlist",
                totalTracks: 100,
                successfulMatches: 85,
                failedMatches: 15,
                matches: [],
                targetPlaylistId: "spotify:playlist:12345",
                targetPlaylistUrl: "https://open.spotify.com/playlist/12345"
            ),
            coordinator: NavigationCoordinator()
        )
    }
}