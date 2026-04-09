import Foundation

nonisolated struct RoadmapTask: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let timeEstimate: String
    let category: AssessmentCategory
    var isCompleted: Bool = false
    var completedDate: Date?
}

nonisolated struct RoadmapWeek: Codable, Identifiable, Sendable {
    let id: String
    let weekNumber: Int
    let theme: String
    let phase: String
    var tasks: [RoadmapTask]
    var isUnlocked: Bool = false
    var insightText: String = ""

    var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(tasks.count)
    }

    var isComplete: Bool {
        !tasks.isEmpty && tasks.allSatisfy(\.isCompleted)
    }
}

nonisolated struct Roadmap: Codable, Sendable {
    var weeks: [RoadmapWeek] = []
    var focusCategories: [AssessmentCategory] = []
    var generatedDate: Date = Date()

    var currentWeekIndex: Int {
        weeks.firstIndex(where: { !$0.isComplete }) ?? (weeks.count - 1)
    }

    var currentWeek: RoadmapWeek? {
        guard !weeks.isEmpty else { return nil }
        let idx = currentWeekIndex
        guard idx >= 0, idx < weeks.count else { return nil }
        return weeks[idx]
    }

    var todaysTask: RoadmapTask? {
        guard let week = currentWeek else { return nil }
        return week.tasks.first(where: { !$0.isCompleted })
    }

    var overallProgress: Double {
        let total = weeks.flatMap(\.tasks).count
        guard total > 0 else { return 0 }
        let completed = weeks.flatMap(\.tasks).filter(\.isCompleted).count
        return Double(completed) / Double(total)
    }
}
