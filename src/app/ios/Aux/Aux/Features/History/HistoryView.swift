import SwiftUI

struct HistoryView: View {
    @StateObject private var historyService = ConversionHistoryService.shared
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            Group {
                if historyService.conversions.isEmpty {
                    emptyStateView
                } else {
                    historyList
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !historyService.conversions.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            showingClearConfirmation = true
                        }
                    }
                }
            }
            .confirmationDialog(
                "Clear History",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All History", role: .destructive) {
                    historyService.clearHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all conversion history. This action cannot be undone.")
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No Conversions Yet")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
            
            Text("Your conversion history will appear here")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    private var historyList: some View {
        List {
            ForEach(historyService.conversions) { record in
                HistoryRow(record: record)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    historyService.deleteConversion(historyService.conversions[index])
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct HistoryRow: View {
    let record: ConversionRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.playlistName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(record.formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Success rate indicator
                ZStack {
                    Circle()
                        .stroke(Color(.tertiarySystemBackground), lineWidth: 2)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: record.successRate)
                        .stroke(successColor(for: record.successRate), lineWidth: 2)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(record.successRate * 100))%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
            
            // Direction
            HStack(spacing: 8) {
                PlatformIcon(platform: record.sourcePlatform, size: 20)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                
                PlatformIcon(platform: record.targetPlatform, size: 20)
                
                Spacer()
                
                // Stats
                HStack(spacing: 12) {
                    Label("\(record.successfulMatches)", systemImage: "checkmark.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("SuccessColor"))
                    
                    if record.failedMatches > 0 {
                        Label("\(record.failedMatches)", systemImage: "xmark.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("ErrorColor"))
                    }
                }
            }
            
            // Open playlist button if available
            if let urlString = record.targetPlaylistUrl,
               let url = URL(string: urlString) {
                Button(action: {
                    UIApplication.shared.open(url)
                }) {
                    Text("Open in \(record.targetPlatform.displayName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("LinkBlue"))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
    
    private func successColor(for rate: Double) -> Color {
        switch rate {
        case 0.8...1.0:
            return Color("SuccessColor")
        case 0.5..<0.8:
            return Color("MediumWarningColor")
        default:
            return Color("ErrorColor")
        }
    }
}

#Preview {
    HistoryView()
}