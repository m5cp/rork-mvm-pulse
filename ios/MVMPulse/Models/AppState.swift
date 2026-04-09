import Foundation

nonisolated enum AppTab: Int, Codable, Sendable {
    case dashboard = 0
    case assess = 1
    case roadmap = 2
    case settings = 3
}

nonisolated enum AppearanceMode: String, Codable, CaseIterable, Sendable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

nonisolated enum ShareCardStyle: String, Codable, CaseIterable, Sendable {
    case light = "Light"
    case dark = "Dark"
    case bold = "Bold"
}
