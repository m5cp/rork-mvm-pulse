import Foundation

struct WeeklyInsight: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let body: String
    let icon: String
    let category: AssessmentCategory?
}

struct InsightsEngine {
    static func generateInsights(result: AssessmentResult, roadmap: Roadmap, streakData: StreakData) -> [WeeklyInsight] {
        var insights: [WeeklyInsight] = []

        if let strongest = result.strongestCategory, let weakest = result.weakestCategory {
            let gap = strongest.normalizedScore - weakest.normalizedScore
            if gap > 30 {
                insights.append(WeeklyInsight(
                    title: "Score Gap Alert",
                    body: "There's a \(Int(gap))-point gap between your strongest area (\(strongest.category.rawValue)) and weakest (\(weakest.category.rawValue)). Closing this gap could lift your overall score by \(Int(gap * 0.3)) points.",
                    icon: "arrow.up.arrow.down",
                    category: weakest.category
                ))
            }
        }

        let completedTasks = roadmap.weeks.flatMap(\.tasks).filter(\.isCompleted).count
        let totalTasks = roadmap.weeks.flatMap(\.tasks).count
        if totalTasks > 0 && completedTasks > 0 {
            let pct = Int(Double(completedTasks) / Double(totalTasks) * 100)
            insights.append(WeeklyInsight(
                title: "Roadmap Progress",
                body: "You've completed \(completedTasks) of \(totalTasks) tasks (\(pct)%). \(pct >= 50 ? "You're past the halfway mark — strong momentum." : "Keep going — consistency beats intensity.")",
                icon: "chart.line.uptrend.xyaxis",
                category: nil
            ))
        }

        if streakData.currentStreak >= 7 {
            insights.append(WeeklyInsight(
                title: "Streak Power",
                body: "Your \(streakData.currentStreak)-day streak puts you in the top tier of consistency. Research shows 21+ consecutive days builds lasting habits.",
                icon: "flame.fill",
                category: nil
            ))
        } else if streakData.currentStreak >= 3 {
            insights.append(WeeklyInsight(
                title: "Building Momentum",
                body: "\(streakData.currentStreak) days in a row. The first week is the hardest — you're \(7 - streakData.currentStreak) days from a major milestone.",
                icon: "bolt.fill",
                category: nil
            ))
        }

        let midScoreCategories = result.categoryScores.filter { $0.normalizedScore >= 40 && $0.normalizedScore < 65 }
        if let quickWin = midScoreCategories.max(by: { $0.normalizedScore < $1.normalizedScore }) {
            insights.append(WeeklyInsight(
                title: "Quick Win Opportunity",
                body: "\(quickWin.category.rawValue) is at \(Int(quickWin.normalizedScore))% — close to the Strong tier. A focused push here could cross the threshold with minimal effort.",
                icon: "target",
                category: quickWin.category
            ))
        }

        let lowCategories = result.categoryScores.filter { $0.normalizedScore < 35 }
        if lowCategories.count >= 3 {
            insights.append(WeeklyInsight(
                title: "Foundation First",
                body: "\(lowCategories.count) categories are below 35%. Focus on your weakest two rather than spreading thin — concentrated effort compounds faster.",
                icon: "building.2.fill",
                category: lowCategories.first?.category
            ))
        }

        if result.overallScore >= 50 && result.overallScore < 65 {
            let pointsToNext = 65 - Int(result.overallScore)
            insights.append(WeeklyInsight(
                title: "Elite is Within Reach",
                body: "You're \(pointsToNext) points from Elite status. Focus on raising your weakest category — it has the highest leverage on your overall score.",
                icon: "star.fill",
                category: result.weakestCategory?.category
            ))
        }

        if insights.isEmpty {
            insights.append(WeeklyInsight(
                title: "Keep Showing Up",
                body: "Consistent daily action is the highest-leverage thing you can do right now. Complete today's task and trust the process.",
                icon: "checkmark.circle.fill",
                category: nil
            ))
        }

        return insights
    }
}
