import Foundation

@Observable
final class AIViewModel {
    let groq = GroqService()
    let usage = AIUsageManager()

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
    var usageLimitHit: Bool = false

    var isAvailable: Bool { groq.isAvailable }

    func currentTier(isPremium: Bool) -> AIUsageTier {
        isPremium ? .premium : .free
    }

    func loadExecutiveSummary(result: AssessmentResult, profile: UserProfile, isPremium: Bool) {
        guard !isLoadingSummary, aiSummary == nil else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.executiveSummary, tier: tier) else {
            usageLimitHit = true
            return
        }
        isLoadingSummary = true
        Task {
            let summary = await groq.generateExecutiveSummary(result: result, profile: profile)
            if summary != nil { usage.recordUsage(.executiveSummary) }
            aiSummary = summary
            isLoadingSummary = false
        }
    }

    func loadDailyTip(result: AssessmentResult, profile: UserProfile, streakDays: Int, isPremium: Bool) {
        guard !isLoadingTip, aiDailyTip == nil else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.dailyTip, tier: tier) else {
            usageLimitHit = true
            return
        }
        isLoadingTip = true
        Task {
            let tip = await groq.generateDailyCoachingTip(result: result, profile: profile, streakDays: streakDays)
            if tip != nil { usage.recordUsage(.dailyTip) }
            aiDailyTip = tip
            isLoadingTip = false
        }
    }

    func loadWeeklyInsights(result: AssessmentResult, profile: UserProfile, completedTasks: Int, totalTasks: Int, isPremium: Bool) {
        guard !isLoadingInsights, aiWeeklyInsights == nil else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.weeklyInsights, tier: tier) else {
            usageLimitHit = true
            return
        }
        isLoadingInsights = true
        Task {
            let insights = await groq.generateWeeklyInsights(result: result, profile: profile, completedTasks: completedTasks, totalTasks: totalTasks)
            if insights != nil { usage.recordUsage(.weeklyInsights) }
            aiWeeklyInsights = insights
            isLoadingInsights = false
        }
    }

    func loadAnswerAnalysis(result: AssessmentResult, profile: UserProfile, isPremium: Bool) {
        guard !isLoadingAnalysis, aiAnswerAnalysis == nil else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.answerAnalysis, tier: tier) else {
            usageLimitHit = true
            return
        }
        isLoadingAnalysis = true
        Task {
            let analysis = await groq.generateAnswerAnalysis(result: result, profile: profile)
            if analysis != nil { usage.recordUsage(.answerAnalysis) }
            aiAnswerAnalysis = analysis
            isLoadingAnalysis = false
        }
    }

    func loadCheckInReflection(mood: CheckInMood, recentMoods: [DailyCheckIn], result: AssessmentResult?, profile: UserProfile, isPremium: Bool) {
        guard !isLoadingReflection else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.checkInReflection, tier: tier) else {
            usageLimitHit = true
            return
        }
        aiCheckInReflection = nil
        isLoadingReflection = true
        Task {
            let moodHistory = recentMoods.suffix(5).map { $0.mood.label }.joined(separator: " \u{2192} ")
            let reflection = await groq.generateCheckInReflection(
                mood: mood.label,
                moodHistory: moodHistory.isEmpty ? "First check-in" : moodHistory,
                result: result,
                profile: profile
            )
            if reflection != nil { usage.recordUsage(.checkInReflection) }
            aiCheckInReflection = reflection
            isLoadingReflection = false
        }
    }

    func loadProgressNarrative(oldResult: AssessmentResult, newResult: AssessmentResult, profile: UserProfile, completedTasks: Int, isPremium: Bool) {
        guard !isLoadingNarrative, aiProgressNarrative == nil else { return }
        let tier = currentTier(isPremium: isPremium)
        guard usage.canPerform(.progressNarrative, tier: tier) else {
            usageLimitHit = true
            return
        }
        isLoadingNarrative = true
        Task {
            let narrative = await groq.generateProgressNarrative(
                oldResult: oldResult,
                newResult: newResult,
                profile: profile,
                completedTasks: completedTasks
            )
            if narrative != nil { usage.recordUsage(.progressNarrative) }
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
        usageLimitHit = false
    }
}
