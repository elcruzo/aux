//
//  AdvancedSettingsView.swift
//  Aux
//
//  Advanced settings and analytics dashboard
//

import SwiftUI
import MessageUI

struct AdvancedSettingsView: View {
    @State private var showingAnalytics = false
    @State private var showingExportSheet = false
    @State private var showingClearDataAlert = false
    @State private var showingMailCompose = false
    @State private var analyticsData = ""
    @State private var conversionStats: ConversionStats?
    @State private var popularConversions: [ConversionDirection] = []
    
    private let analyticsService = AnalyticsService.shared
    
    var body: some View {
        NavigationView {
            List {
                analyticsSection
                dataSection
                debugSection
                supportSection
            }
            .navigationTitle("Advanced Settings")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadAnalyticsData()
            }
        }
    }
    
    private var analyticsSection: some View {
        Section(header: Text("Analytics & Insights")) {
            Button(action: { showingAnalytics = true }) {
                Label("View Analytics Dashboard", systemImage: "chart.bar")
                    .foregroundColor(.primary)
            }
            
            if let stats = conversionStats {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Total Conversions")
                        Spacer()
                        Text("\(stats.totalConversions)")
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Success Rate")
                        Spacer()
                        Text("\(String(format: "%.1f", stats.successRate * 100))%")
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Avg. Conversion Time")
                        Spacer()
                        Text("\(String(format: "%.1f", stats.avgConversionTime))s")
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsDashboardView(stats: conversionStats, conversions: popularConversions)
        }
    }
    
    private var dataSection: some View {
        Section(header: Text("Data Management")) {
            Button(action: { 
                analyticsData = analyticsService.exportAnalyticsData()
                showingExportSheet = true 
            }) {
                Label("Export Analytics Data", systemImage: "square.and.arrow.up")
                    .foregroundColor(.primary)
            }
            
            Button(action: { showingClearDataAlert = true }) {
                Label("Clear All Data", systemImage: "trash")
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ActivityViewController(activityItems: [analyticsData])
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                analyticsService.clearAnalyticsData()
                Task { await loadAnalyticsData() }
            }
        } message: {
            Text("This will permanently delete all conversion history, analytics data, and preferences. This action cannot be undone.")
        }
    }
    
    private var debugSection: some View {
        Section(header: Text("Debug Information")) {
            VStack(alignment: .leading, spacing: 8) {
                debugRow("App Version", AppConfiguration.appVersion)
                debugRow("Build Number", AppConfiguration.buildNumber)
                debugRow("Environment", AppConfiguration.environment)
                debugRow("API Base URL", AppConfiguration.apiBaseURL)
                debugRow("Bundle ID", AppConfiguration.bundleIdentifier)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    private var supportSection: some View {
        Section(header: Text("Support & Feedback")) {
            Button(action: { showingMailCompose = true }) {
                Label("Send Feedback", systemImage: "envelope")
                    .foregroundColor(.primary)
            }
            
            Button(action: { openAPIDocumentation() }) {
                Label("API Documentation", systemImage: "doc.text")
                    .foregroundColor(.primary)
            }
            
            Button(action: { openGitHubRepository() }) {
                Label("View Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                    .foregroundColor(.primary)
            }
        }
        .sheet(isPresented: $showingMailCompose) {
            if MFMailComposeViewController.canSendMail() {
                MailComposeView(
                    subject: "Aux App Feedback",
                    recipients: ["ayomideadekoya266@gmail.com"],
                    body: generateFeedbackBody()
                )
            } else {
                Text("Mail not configured")
                    .padding()
            }
        }
    }
    
    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
    
    private func loadAnalyticsData() async {
        conversionStats = await analyticsService.getConversionStats()
        popularConversions = await analyticsService.getPopularConversions()
    }
    
    private func generateFeedbackBody() -> String {
        return """
        
        
        ---
        Debug Information:
        App Version: \(AppConfiguration.appVersion) (\(AppConfiguration.buildNumber))
        Environment: \(AppConfiguration.environment)
        API Base: \(AppConfiguration.apiBaseURL)
        Device: \(UIDevice.current.model)
        iOS Version: \(UIDevice.current.systemVersion)
        """
    }
    
    private func openAPIDocumentation() {
        if let url = URL(string: AppConfiguration.apiDocsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openGitHubRepository() {
        if let url = URL(string: "https://github.com/elcruzo/aux") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Analytics Dashboard
struct AnalyticsDashboardView: View {
    let stats: ConversionStats?
    let conversions: [ConversionDirection]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if let stats = stats {
                        overviewCards(stats)
                        conversionChart(conversions)
                        detailedStats(stats)
                    } else {
                        Text("No analytics data available")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func overviewCards(_ stats: ConversionStats) -> some View {
        HStack(spacing: 16) {
            AnalyticsCard(
                title: "Total Conversions",
                value: "\(stats.totalConversions)",
                icon: "music.note.list",
                color: .blue
            )
            
            AnalyticsCard(
                title: "Success Rate",
                value: "\(String(format: "%.1f", stats.successRate * 100))%",
                icon: "checkmark.circle",
                color: .green
            )
        }
    }
    
    private func conversionChart(_ conversions: [ConversionDirection]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Conversion Directions")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(conversions.prefix(5), id: \.fromPlatform) { direction in
                ConversionDirectionRow(direction: direction)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func detailedStats(_ stats: ConversionStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatRow(label: "Average Conversion Time", value: "\(String(format: "%.1f", stats.avgConversionTime))s")
                StatRow(label: "Average Playlist Size", value: "\(stats.avgPlaylistSize) tracks")
                StatRow(label: "Weekly Growth", value: "\(String(format: "%.1f", stats.weeklyGrowth))%")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ConversionDirectionRow: View {
    let direction: ConversionDirection
    
    var body: some View {
        HStack {
            PlatformIcon(platform: direction.fromPlatform, size: 20)
            
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PlatformIcon(platform: direction.toPlatform, size: 20)
            
            Text("\(direction.fromPlatform) → \(direction.toPlatform)")
                .font(.subheadline)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(direction.count)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(String(format: "%.1f", direction.percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Supporting Views
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let recipients: [String]
    let body: String
    
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setSubject(subject)
        controller.setToRecipients(recipients)
        controller.setMessageBody(body, isHTML: false)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}