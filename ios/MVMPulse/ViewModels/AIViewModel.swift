import Foundation

@Observable
final class AIViewModel {
    private let groq = GroqService()

    var aiSummary: String?
    var aiDailyTip: String?
    var aiWeeklyInsights: [String]?
    var isLoadingSummary: Bool = false
    var isLoadingTip: Bool = false
    var isLoadingInsights: Bool = false

    var isAvailable: Bool { groq.isAvailable }

    func loadExecutiveSummary(result: AssessmentResult, profile: UserProfile) {
        guard !isLoadingSummary, aiSummary == nil else { return }
        isLoadingSummary = true
        Task {
            let summary = await groq.generateExecutiveSummary(result: result, profile: profile)
            aiSummary = summary
            isLoadingSummary = false
        }
    }

    func loadDailyTip(result: AssessmentResult, profile: UserProfile, streakDays: Int) {
        guard !isLoadingTip, aiDailyTip == nil else { return }
        isLoadingTip = true
        Task {
            let tip = await groq.generateDailyCoachingTip(result: result, profile: profile, streakDays: streakDays)
            aiDailyTip = tip
            isLoadingTip = false
        }
    }

    func loadWeeklyInsights(result: AssessmentResult, profile: UserProfile, completedTasks: Int, totalTasks: Int) {
        guard !isLoadingInsights, aiWeeklyInsights == nil else { return }
        isLoadingInsights = true
        Task {
            let insights = await groq.generateWeeklyInsights(result: result, profile: profile, completedTasks: completedTasks, totalTasks: totalTasks)
            aiWeeklyInsights = insights
            isLoadingInsights = false
        }
    }

    func resetForNewResult() {
        aiSummary = nil
        aiDailyTip = nil
        aiWeeklyInsights = nil
    }
}
