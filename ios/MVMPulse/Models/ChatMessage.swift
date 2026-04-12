import Foundation

nonisolated struct ChatMessage: Codable, Identifiable, Sendable {
    let id: String
    let role: ChatRole
    let content: String
    let timestamp: Date

    init(id: String = UUID().uuidString, role: ChatRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

nonisolated enum ChatRole: String, Codable, Sendable {
    case user
    case assistant
}
