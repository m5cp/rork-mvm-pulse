import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

@Observable
final class AppleIntelligenceService {
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.isAvailable
        }
        #endif
        return false
    }

    var availabilityDetail: String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return "available"
            case .unavailable(.appleIntelligenceNotEnabled):
                return "Apple Intelligence not enabled"
            case .unavailable(.modelNotReady):
                return "Model downloading"
            case .unavailable(.deviceNotEligible):
                return "Device not eligible"
            default:
                return "unavailable"
            }
        }
        #endif
        return "Requires iOS 26+"
    }

    func generate(prompt: String, systemPrompt: String) async -> String? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard isAvailable else { return nil }
            do {
                let session = LanguageModelSession {
                    systemPrompt
                }
                let response = try await session.respond(to: prompt)
                return response.content
            } catch {
                return nil
            }
        }
        #endif
        return nil
    }

    func chatConversation(messages: [(role: String, content: String)], systemPrompt: String) async -> String? {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            guard isAvailable else { return nil }

            var conversationContext = ""
            for msg in messages {
                let label = msg.role == "user" ? "User" : "Assistant"
                conversationContext += "\(label): \(msg.content)\n\n"
            }

            let fullPrompt = """
            Continue this conversation. Respond only as the Assistant. Do not include any prefix like "Assistant:".

            \(conversationContext)
            Assistant:
            """

            do {
                let session = LanguageModelSession {
                    systemPrompt
                }
                let response = try await session.respond(to: fullPrompt)
                return response.content
            } catch {
                return nil
            }
        }
        #endif
        return nil
    }
}
