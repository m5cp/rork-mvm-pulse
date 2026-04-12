import Foundation

nonisolated enum AIActionType: String, CaseIterable, Sendable {
    case chatMessage
    case executiveSummary
    case dailyTip
    case weeklyInsights
    case answerAnalysis
    case checkInReflection
    case progressNarrative
    case categoryQA
    case categoryInsight
}

nonisolated enum AIUsageTier: Sendable {
    case free
    case premium
}

nonisolated struct AIUsageLimits: Sendable {
    let chatMessagesPerDay: Int
    let autoInsightsPerDay: Int
    let categoryQAPerDay: Int

    static let free = AIUsageLimits(
        chatMessagesPerDay: 0,
        autoInsightsPerDay: 5,
        categoryQAPerDay: 2
    )

    static let premium = AIUsageLimits(
        chatMessagesPerDay: 50,
        autoInsightsPerDay: 25,
        categoryQAPerDay: 15
    )
}

@Observable
final class AIUsageManager {
    private let defaults = UserDefaults.standard

    private(set) var chatUsedToday: Int = 0
    private(set) var insightsUsedToday: Int = 0
    private(set) var categoryQAUsedToday: Int = 0

    private let chatKey = "ai_usage_chat"
    private let insightsKey = "ai_usage_insights"
    private let categoryQAKey = "ai_usage_categoryQA"
    private let dateKey = "ai_usage_date"

    init() {
        resetIfNewDay()
        loadCounts()
    }

    func limits(for tier: AIUsageTier) -> AIUsageLimits {
        switch tier {
        case .free: .free
        case .premium: .premium
        }
    }

    func canPerform(_ action: AIActionType, tier: AIUsageTier) -> Bool {
        resetIfNewDay()
        let lim = limits(for: tier)

        switch action {
        case .chatMessage:
            return chatUsedToday < lim.chatMessagesPerDay
        case .categoryQA:
            return categoryQAUsedToday < lim.categoryQAPerDay
        case .executiveSummary, .dailyTip, .weeklyInsights, .answerAnalysis,
             .checkInReflection, .progressNarrative, .categoryInsight:
            return insightsUsedToday < lim.autoInsightsPerDay
        }
    }

    func recordUsage(_ action: AIActionType) {
        resetIfNewDay()

        switch action {
        case .chatMessage:
            chatUsedToday += 1
            defaults.set(chatUsedToday, forKey: chatKey)
        case .categoryQA:
            categoryQAUsedToday += 1
            defaults.set(categoryQAUsedToday, forKey: categoryQAKey)
        case .executiveSummary, .dailyTip, .weeklyInsights, .answerAnalysis,
             .checkInReflection, .progressNarrative, .categoryInsight:
            insightsUsedToday += 1
            defaults.set(insightsUsedToday, forKey: insightsKey)
        }
    }

    func remaining(_ action: AIActionType, tier: AIUsageTier) -> Int {
        resetIfNewDay()
        let lim = limits(for: tier)

        switch action {
        case .chatMessage:
            return max(0, lim.chatMessagesPerDay - chatUsedToday)
        case .categoryQA:
            return max(0, lim.categoryQAPerDay - categoryQAUsedToday)
        case .executiveSummary, .dailyTip, .weeklyInsights, .answerAnalysis,
             .checkInReflection, .progressNarrative, .categoryInsight:
            return max(0, lim.autoInsightsPerDay - insightsUsedToday)
        }
    }

    func usageSummary(tier: AIUsageTier) -> String {
        let lim = limits(for: tier)
        switch tier {
        case .free:
            return "\(insightsUsedToday)/\(lim.autoInsightsPerDay) insights \u{00B7} \(categoryQAUsedToday)/\(lim.categoryQAPerDay) Q&A"
        case .premium:
            return "\(chatUsedToday)/\(lim.chatMessagesPerDay) chats \u{00B7} \(insightsUsedToday)/\(lim.autoInsightsPerDay) insights \u{00B7} \(categoryQAUsedToday)/\(lim.categoryQAPerDay) Q&A"
        }
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = defaults.object(forKey: dateKey) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: stored)

        if today > storedDay {
            defaults.set(today, forKey: dateKey)
            defaults.set(0, forKey: chatKey)
            defaults.set(0, forKey: insightsKey)
            defaults.set(0, forKey: categoryQAKey)
            chatUsedToday = 0
            insightsUsedToday = 0
            categoryQAUsedToday = 0
        }
    }

    private func loadCounts() {
        chatUsedToday = defaults.integer(forKey: chatKey)
        insightsUsedToday = defaults.integer(forKey: insightsKey)
        categoryQAUsedToday = defaults.integer(forKey: categoryQAKey)
    }
}
