//
//  IntentsExtension.swift
//  Aux
//
//  Siri Shortcuts support for voice-activated conversions
//

import Intents
import IntentsUI
import Foundation

// MARK: - Convert Playlist Intent
@available(iOS 14.0, *)
class ConvertPlaylistIntentHandler: NSObject, ConvertPlaylistIntentHandling {
    
    func handle(intent: ConvertPlaylistIntent, completion: @escaping (ConvertPlaylistIntentResponse) -> Void) {
        guard let playlistURL = intent.playlistURL,
              let url = URL(string: playlistURL) else {
            completion(ConvertPlaylistIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        Task {
            do {
                let conversionService = ServiceFactory.shared.conversionService
                let result = try await conversionService.convertPlaylist(from: url)
                
                let response = ConvertPlaylistIntentResponse(code: .success, userActivity: nil)
                response.playlistName = result.destinationPlaylistName
                response.platform = result.destinationPlatform
                completion(response)
                
            } catch {
                let response = ConvertPlaylistIntentResponse(code: .failure, userActivity: nil)
                response.errorMessage = error.localizedDescription
                completion(response)
            }
        }
    }
    
    func resolvePlaylistURL(for intent: ConvertPlaylistIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let playlistURL = intent.playlistURL, !playlistURL.isEmpty else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        
        // Validate URL format
        guard URL(string: playlistURL) != nil else {
            completion(INStringResolutionResult.unsupported(forReason: .invalid))
            return
        }
        
        completion(INStringResolutionResult.success(with: playlistURL))
    }
}

// MARK: - Get Recent Conversions Intent
@available(iOS 14.0, *)
class GetRecentConversionsIntentHandler: NSObject, GetRecentConversionsIntentHandling {
    
    func handle(intent: GetRecentConversionsIntent, completion: @escaping (GetRecentConversionsIntentResponse) -> Void) {
        Task {
            do {
                let historyService = ConversionHistoryService()
                let limit = max(1, min(intent.limit?.intValue ?? 5, 10))
                let conversions = await historyService.getRecentConversions(limit: limit)
                
                let response = GetRecentConversionsIntentResponse(code: .success, userActivity: nil)
                response.conversions = conversions.map { conversion in
                    let intentConversion = IntentConversion()
                    intentConversion.playlistName = conversion.sourcePlaylistName
                    intentConversion.sourcePlatform = conversion.sourcePlatform
                    intentConversion.destinationPlatform = conversion.destinationPlatform
                    intentConversion.convertedAt = conversion.convertedAt
                    return intentConversion
                }
                
                completion(response)
                
            } catch {
                let response = GetRecentConversionsIntentResponse(code: .failure, userActivity: nil)
                completion(response)
            }
        }
    }
    
    func resolveLimit(for intent: GetRecentConversionsIntent, with completion: @escaping (INIntegerResolutionResult) -> Void) {
        let limit = intent.limit?.intValue ?? 5
        let clampedLimit = max(1, min(limit, 10))
        completion(INIntegerResolutionResult.success(with: clampedLimit))
    }
}

// MARK: - Intent Extension
@available(iOS 14.0, *)
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is ConvertPlaylistIntent:
            return ConvertPlaylistIntentHandler()
        case is GetRecentConversionsIntent:
            return GetRecentConversionsIntentHandler()
        default:
            fatalError("Unhandled intent type: \(intent)")
        }
    }
}

// MARK: - Supporting Types
class IntentConversion: NSObject {
    var playlistName: String?
    var sourcePlatform: String?
    var destinationPlatform: String?
    var convertedAt: Date?
}

// MARK: - Shortcuts Donation Helper
extension ConversionService {
    
    @available(iOS 14.0, *)
    func donateConvertPlaylistShortcut(playlistURL: String, playlistName: String) {
        let intent = ConvertPlaylistIntent()
        intent.playlistURL = playlistURL
        intent.suggestedInvocationPhrase = "Convert \(playlistName) playlist"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Failed to donate shortcut: \(error)")
            } else {
                print("Successfully donated convert playlist shortcut")
            }
        }
    }
    
    @available(iOS 14.0, *)
    func donateRecentConversionsShortcut() {
        let intent = GetRecentConversionsIntent()
        intent.suggestedInvocationPhrase = "Show my recent playlist conversions"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Failed to donate shortcut: \(error)")
            } else {
                print("Successfully donated recent conversions shortcut")
            }
        }
    }
}

// MARK: - Intent Definitions (would normally be in Intents.intentdefinition)
@available(iOS 14.0, *)
class ConvertPlaylistIntent: INIntent {
    @NSManaged public var playlistURL: String?
}

@available(iOS 14.0, *)
class ConvertPlaylistIntentResponse: INIntentResponse {
    @NSManaged public var playlistName: String?
    @NSManaged public var platform: String?
    @NSManaged public var errorMessage: String?
}

@available(iOS 14.0, *)
class GetRecentConversionsIntent: INIntent {
    @NSManaged public var limit: NSNumber?
}

@available(iOS 14.0, *)
class GetRecentConversionsIntentResponse: INIntentResponse {
    @NSManaged public var conversions: [IntentConversion]?
}