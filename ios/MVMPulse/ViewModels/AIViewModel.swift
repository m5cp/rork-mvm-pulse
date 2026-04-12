import Foundation

@Observable
final class AIViewModel {
    let groq = GroqService()

    var aiSummary: String?
    var aiDailyTip: String?
    var aiWeeklyInsights: [String]?
    var aiAnswerAnalysis: String?
    var aiCheckInReflection: String?
    var aiProgressNarrative: String?
    var isLoadingSummary: Bool = false
    var isLoadingTip: Bool = false
    var isLoadingInsights: Bool = false
    var isLoadingAnalysis: Bool = false
    var isLoadingReflection: Bool = false
    var isLoadingNarrative: Bool = false

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

    func loadAnswerAnalysis(result: AssessmentResult, profile: UserProfile) {
        guard !isLoadingAnalysis, aiAnswerAnalysis == nil else { return }
        isLoadingAnalysis = true
        Task {
            let analysis = await groq.generateAnswerAnalysis(result: result, profile: profile)
            aiAnswerAnalysis = analysis
            isLoadingAnalysis = false
        }
    }

    func loadCheckInReflection(mood: CheckInMood, recentMoods: [DailyCheckIn], result: AssessmentResult?, profile: UserProfile) {
        guard !isLoadingReflection else { return }
        aiCheckInReflection = nil
        isLoadingReflection = true
        Task {
            let moodHistory = recentMoods.suffix(5).map { $0.mood.label }.joined(separator: " → ")
            let reflection = await groq.generateCheckInReflection(
                mood: mood.label,
                moodHistory: moodHistory.isEmpty ? "First check-in" : moodHistory,
                result: result,
                profile: profile
            )
            aiCheckInReflection = reflection
            isLoadingReflection = false
        }
    }

    func loadProgressNarrative(oldResult: AssessmentResult, newResult: AssessmentResult, profile: UserProfile, completedTasks: Int) {
        guard !isLoadingNarrative, aiProgressNarrative == nil else { return }
        isLoadingNarrative = true
        Task {
            let narrative = await groq.generateProgressNarrative(
                oldResult: oldResult,
                newResult: newResult,
                profile: profile,
                completedTasks: completedTasks
            )
            aiProgressNarrative = narrative
            isLoadingNarrative = false
        }
    }

    func resetForNewResult() {
        aiSummary = nil
        aiDailyTip = nil
        aiWeeklyInsights = nil
        aiAnswerAnalysis = nil
        aiProgressNarrative = nil
    }
}
