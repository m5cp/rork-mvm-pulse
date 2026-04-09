import AppIntents
import SwiftUI

struct GetPulseScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Pulse Score"
    static var description = IntentDescription("Check your current MVM Pulse Score.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "mvmpulse_assessment_results"),
              let results = try? JSONDecoder().decode([IntentAssessmentResult].self, from: data),
              let latest = results.last else {
            return .result(dialog: "You haven't taken an assessment yet. Open MVM Pulse to get started.")
        }
        let score = Int(latest.overallScore)
        let level = latest.level
        return .result(dialog: "Your Pulse Score is \(score), rated \(level).")
    }
}

struct StartDailyTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Daily Task"
    static var description = IntentDescription("Open your current daily task in MVM Pulse.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: "mvmpulse_roadmap"),
              let roadmap = try? JSONDecoder().decode(IntentRoadmap.self, from: data),
              let task = roadmap.currentTaskTitle, !task.isEmpty else {
            return .result(dialog: "No daily task available. Complete an assessment first.")
        }
        return .result(dialog: "Today's task: \(task)")
    }
}

nonisolated struct IntentAssessmentResult: Codable, Sendable {
    let overallScore: Double
    let level: String
}

nonisolated struct IntentRoadmap: Codable, Sendable {
    let weeks: [IntentWeek]

    var currentTaskTitle: String? {
        for week in weeks {
            if let task = week.tasks.first(where: { !$0.isCompleted }) {
                return task.title
            }
        }
        return nil
    }
}

nonisolated struct IntentWeek: Codable, Sendable {
    let tasks: [IntentTask]
}

nonisolated struct IntentTask: Codable, Sendable {
    let title: String
    let isCompleted: Bool
}

struct MVMPulseShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetPulseScoreIntent(),
            phrases: [
                "What's my Pulse Score in \(.applicationName)",
                "Check my score in \(.applicationName)",
                "Get my \(.applicationName) score"
            ],
            shortTitle: "Pulse Score",
            systemImageName: "waveform.path.ecg"
        )
        AppShortcut(
            intent: StartDailyTaskIntent(),
            phrases: [
                "Start my daily task in \(.applicationName)",
                "What's my task in \(.applicationName)",
                "Open today's task in \(.applicationName)"
            ],
            shortTitle: "Daily Task",
            systemImageName: "checkmark.circle"
        )
    }

    static var shortcutTileColor: ShortcutTileColor = .teal
}
