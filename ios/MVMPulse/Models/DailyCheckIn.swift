import Foundation

nonisolated struct DailyCheckIn: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    let mood: CheckInMood
    let note: String

    init(id: String = UUID().uuidString, date: Date = Date(), mood: CheckInMood, note: String = "") {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
    }
}

nonisolated enum CheckInMood: Int, Codable, CaseIterable, Sendable {
    case struggling = 1
    case tough = 2
    case okay = 3
    case good = 4
    case great = 5

    var emoji: String {
        switch self {
        case .struggling: "\u{1F623}"
        case .tough: "\u{1F615}"
        case .okay: "\u{1F610}"
        case .good: "\u{1F60A}"
        case .great: "\u{1F525}"
        }
    }

    var label: String {
        switch self {
        case .struggling: "Struggling"
        case .tough: "Tough"
        case .okay: "Okay"
        case .good: "Good"
        case .great: "Great"
        }
    }
}

nonisolated struct GoalData: Codable, Sendable {
    var targetScore: Double
    var targetDate: Date
    var setDate: Date

    init(targetScore: Double = 65, targetDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date(), setDate: Date = Date()) {
        self.targetScore = targetScore
        self.targetDate = targetDate
        self.setDate = setDate
    }
}
