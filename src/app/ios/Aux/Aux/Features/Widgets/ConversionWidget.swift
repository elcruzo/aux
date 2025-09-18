//
//  ConversionWidget.swift
//  Aux
//
//  Widget Extension for quick playlist conversions
//

import SwiftUI
import WidgetKit

struct ConversionWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ConversionEntry {
        ConversionEntry(date: Date(), recentConversion: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ConversionEntry) -> ()) {
        let entry = ConversionEntry(date: Date(), recentConversion: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ConversionEntry>) -> ()) {
        Task {
            let recentConversion = await fetchRecentConversion()
            let entry = ConversionEntry(date: Date(), recentConversion: recentConversion)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchRecentConversion() async -> RecentConversion? {
        // Fetch from conversion history service
        do {
            let historyService = ConversionHistoryService()
            let history = await historyService.getHistory(limit: 1)
            return history.first.map { conversion in
                RecentConversion(
                    playlistName: conversion.sourcePlaylistName,
                    sourcePlatform: Track.Platform(rawValue: conversion.sourcePlatform) ?? .spotify,
                    destinationPlatform: Track.Platform(rawValue: conversion.destinationPlatform) ?? .apple,
                    convertedAt: conversion.convertedAt
                )
            }
        } catch {
            return nil
        }
    }
}

struct ConversionEntry: TimelineEntry {
    let date: Date
    let recentConversion: RecentConversion?
}

struct RecentConversion {
    let playlistName: String
    let sourcePlatform: Track.Platform
    let destinationPlatform: Track.Platform
    let convertedAt: Date
}

struct ConversionWidgetEntryView: View {
    var entry: ConversionEntry
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("Aux")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let recent = entry.recentConversion {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last Converted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(recent.playlistName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    HStack {
                        PlatformIcon(platform: recent.sourcePlatform, size: 16)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        PlatformIcon(platform: recent.destinationPlatform, size: 16)
                        
                        Spacer()
                        
                        Text(recent.convertedAt, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Tap to convert playlists")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .containerBackground(.clear, for: .widget)
    }
}

struct ConversionWidget: Widget {
    let kind: String = "ConversionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ConversionWidgetProvider()) { entry in
            ConversionWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Convert")
        .description("Convert playlists between Spotify and Apple Music")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}