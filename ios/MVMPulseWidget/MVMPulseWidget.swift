import WidgetKit
import SwiftUI

nonisolated struct PulseEntry: TimelineEntry {
    let date: Date
    let score: Int
    let level: String
    let streak: Int
    let todaysTask: String
    let hasData: Bool
}

nonisolated struct PulseProvider: TimelineProvider {
    func placeholder(in context: Context) -> PulseEntry {
        PulseEntry(date: .now, score: 72, level: "ELITE", streak: 14, todaysTask: "Review your cash flow", hasData: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (PulseEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PulseEntry>) -> Void) {
        let defaults = UserDefaults.standard
        let entry: PulseEntry

        if let resultData = defaults.data(forKey: "mvmpulse_assessment_results"),
           let results = try? JSONDecoder().decode([WidgetAssessmentResult].self, from: resultData),
           let latest = results.last {
            let streakData = defaults.data(forKey: "mvmpulse_streak_data").flatMap { try? JSONDecoder().decode(WidgetStreakData.self, from: $0) }
            let roadmapData = defaults.data(forKey: "mvmpulse_roadmap").flatMap { try? JSONDecoder().decode(WidgetRoadmap.self, from: $0) }

            let taskTitle = roadmapData?.currentTaskTitle ?? ""

            entry = PulseEntry(
                date: .now,
                score: Int(latest.overallScore),
                level: latest.level.uppercased(),
                streak: streakData?.currentStreak ?? 0,
                todaysTask: taskTitle,
                hasData: true
            )
        } else {
            entry = PulseEntry(date: .now, score: 0, level: "", streak: 0, todaysTask: "", hasData: false)
        }

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

nonisolated struct WidgetAssessmentResult: Codable, Sendable {
    let id: String
    let date: Date
    let overallScore: Double
    let level: String
}

nonisolated struct WidgetStreakData: Codable, Sendable {
    let currentStreak: Int
}

nonisolated struct WidgetRoadmap: Codable, Sendable {
    let weeks: [WidgetWeek]

    var currentTaskTitle: String {
        for week in weeks {
            if let task = week.tasks.first(where: { !$0.isCompleted }) {
                return task.title
            }
        }
        return ""
    }
}

nonisolated struct WidgetWeek: Codable, Sendable {
    let tasks: [WidgetTask]
}

nonisolated struct WidgetTask: Codable, Sendable {
    let title: String
    let isCompleted: Bool
}

let tealColor = Color(red: 9/255, green: 119/255, blue: 112/255)

struct SmallWidgetView: View {
    let entry: PulseEntry

    var body: some View {
        if entry.hasData {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(tealColor.opacity(0.2), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: Double(entry.score) / 100.0)
                        .stroke(tealColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(entry.score)")
                        .font(.system(size: 28, weight: .heavy))
                }
                .frame(width: 70, height: 70)

                Text(entry.level)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(tealColor)
                    .tracking(1)

                if entry.streak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text("\(entry.streak)d")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.title2)
                    .foregroundStyle(tealColor)
                Text("Take your first assessment")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct MediumWidgetView: View {
    let entry: PulseEntry

    var body: some View {
        if entry.hasData {
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .stroke(tealColor.opacity(0.2), lineWidth: 5)
                        Circle()
                            .trim(from: 0, to: Double(entry.score) / 100.0)
                            .stroke(tealColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(entry.score)")
                            .font(.system(size: 24, weight: .heavy))
                    }
                    .frame(width: 60, height: 60)

                    Text(entry.level)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(tealColor)
                        .tracking(1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    if entry.streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(entry.streak)-day streak")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !entry.todaysTask.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TODAY'S TASK")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(tealColor)
                                .tracking(0.5)
                            Text(entry.todaysTask)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(2)
                        }
                    }

                    HStack(spacing: 2) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 8))
                            .foregroundStyle(tealColor)
                        Text("MVM Pulse")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 0)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            HStack(spacing: 16) {
                Image(systemName: "waveform.path.ecg")
                    .font(.title)
                    .foregroundStyle(tealColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text("MVM Pulse")
                        .font(.subheadline.bold())
                    Text("Take your first assessment to see your score here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct MVMPulseWidget: Widget {
    let kind: String = "MVMPulseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PulseProvider()) { entry in
            WidgetFamilyView(entry: entry)
        }
        .configurationDisplayName("Pulse Score")
        .description("See your Pulse Score, streak, and today's task at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WidgetFamilyView: View {
    @Environment(\.widgetFamily) private var family
    let entry: PulseEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
