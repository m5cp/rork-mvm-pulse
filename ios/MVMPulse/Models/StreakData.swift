import Foundation

nonisolated struct StreakData: Codable, Sendable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActivityDate: Date?
    var totalDaysActive: Int = 0
    var milestones: [StreakMilestone] = []

    var isActiveToday: Bool {
        guard let last = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var streakBroken: Bool {
        guard let last = lastActivityDate else { return false }
        guard !Calendar.current.isDateInToday(last) else { return false }
        guard !Calendar.current.isDateInYesterday(last) else { return false }
        return true
    }

    var comebackMessage: String? {
        guard streakBroken else { return nil }
        guard let last = lastActivityDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        if days <= 3 { return "Welcome back. Let's pick up where you left off." }
        if days <= 7 { return "A few days away. Your roadmap is waiting." }
        return "Good to see you again. Progress isn't always linear."
    }
}

nonisolated struct StreakMilestone: Codable, Identifiable, Sendable {
    let id: String
    let days: Int
    let title: String
    let achievedDate: Date

    static let milestoneThresholds = [7, 30, 90]
}
