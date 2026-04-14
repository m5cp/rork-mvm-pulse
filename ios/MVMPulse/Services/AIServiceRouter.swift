import Foundation

@Observable
final class AIServiceRouter {
    let appleAI = AppleIntelligenceService()
    let groq = GroqService()

    private let systemPrompt = "You are MVM Pulse, a premium AI-powered business and life health diagnostic assistant. Be concise, direct, and insightful."

    enum AIProvider: String {
        case appleIntelligence = "Apple Intelligence"
        case groq = "Groq Cloud"
        case none = "Unavailable"
    }

    var activeProvider: AIProvider {
        if appleAI.isAvailable { return .appleIntelligence }
        if groq.isAvailable { return .groq }
        return .none
    }

    var isAvailable: Bool {
        appleAI.isAvailable || groq.isAvailable
    }

    var providerStatusDescription: String {
        if appleAI.isAvailable {
            return "On-device AI (Apple Intelligence)"
        } else if groq.isAvailable {
            return "Cloud AI (Groq)"
        } else {
            return "AI unavailable — \(appleAI.availabilityDetail)"
        }
    }

    func generateExecutiveSummary(result: AssessmentResult, profile: UserProfile) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildExecutiveSummaryPrompt(result: result, profile: profile)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateExecutiveSummary(result: result, profile: profile)
    }

    func generateCategoryInsight(category: AssessmentCategory, score: Double, profile: UserProfile) async -> String? {
        if appleAI.isAvailable {
            let prompt = """
            Generate a personalized 2-sentence insight for this category score.

            Category: \(category.rawValue)
            Score: \(Int(score))%
            User: \(profile.role.rawValue) in \(profile.industry.rawValue)

            Be specific to their role and industry. Reference actionable next steps. No fluff.
            """
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateCategoryInsight(category: category, score: score, profile: profile)
    }

    func generateDailyCoachingTip(result: AssessmentResult, profile: UserProfile, streakDays: Int) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildDailyTipPrompt(result: result, profile: profile, streakDays: streakDays)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateDailyCoachingTip(result: result, profile: profile, streakDays: streakDays)
    }

    func generateWeeklyInsights(result: AssessmentResult, profile: UserProfile, completedTasks: Int, totalTasks: Int) async -> [String]? {
        if appleAI.isAvailable {
            let prompt = buildWeeklyInsightsPrompt(result: result, profile: profile, completedTasks: completedTasks, totalTasks: totalTasks)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
                if let data = trimmed.data(using: .utf8),
                   let insights = try? JSONDecoder().decode([String].self, from: data) {
                    return insights
                }
                return [response]
            }
        }
        return await groq.generateWeeklyInsights(result: result, profile: profile, completedTasks: completedTasks, totalTasks: totalTasks)
    }

    func generateAnswerAnalysis(result: AssessmentResult, profile: UserProfile) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildAnswerAnalysisPrompt(result: result, profile: profile)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateAnswerAnalysis(result: result, profile: profile)
    }

    func generateCheckInReflection(mood: String, moodHistory: String, result: AssessmentResult?, profile: UserProfile) async -> String? {
        if appleAI.isAvailable {
            let scoreContext: String
            if let result {
                let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
                let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
                scoreContext = "Pulse Score: \(Int(result.overallScore))/100. Weakest area: \(weakest) at \(weakestScore)%."
            } else {
                scoreContext = "No assessment completed yet."
            }

            let prompt = """
            The user just logged their mood as "\(mood)". Recent mood trend: \(moodHistory). \(scoreContext)
            Profile: \(profile.role.rawValue) in \(profile.industry.rawValue)

            Write a brief, empathetic 2-sentence reflection connecting their mood to their business context. If mood is declining, gently suggest it may be systemic. If improving, reinforce what's working. Be warm but not patronizing.
            """
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateCheckInReflection(mood: mood, moodHistory: moodHistory, result: result, profile: profile)
    }

    func generateProgressNarrative(oldResult: AssessmentResult, newResult: AssessmentResult, profile: UserProfile, completedTasks: Int) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildProgressNarrativePrompt(oldResult: oldResult, newResult: newResult, profile: profile, completedTasks: completedTasks)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateProgressNarrative(oldResult: oldResult, newResult: newResult, profile: profile, completedTasks: completedTasks)
    }

    func generateCategoryQA(category: AssessmentCategory, score: Double, question: String, profile: UserProfile) async -> String? {
        if appleAI.isAvailable {
            let prompt = """
            The user is asking about their \(category.rawValue) score of \(Int(score))%.

            Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)

            Their question: \(question)

            Answer in 2-4 sentences. Be specific to their industry and role. Give actionable advice, not theory. Reference their score when relevant.
            """
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateCategoryQA(category: category, score: score, question: question, profile: profile)
    }

    func generateWeeklyRecap(weekNumber: Int, completedTasks: Int, totalTasks: Int, result: AssessmentResult, profile: UserProfile, streakDays: Int) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildWeeklyRecapPrompt(weekNumber: weekNumber, completedTasks: completedTasks, totalTasks: totalTasks, result: result, profile: profile, streakDays: streakDays)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateWeeklyRecap(weekNumber: weekNumber, completedTasks: completedTasks, totalTasks: totalTasks, result: result, profile: profile, streakDays: streakDays)
    }

    func generateExecutiveBriefing(results: [AssessmentResult], profile: UserProfile, roadmapProgress: Double, completedTasks: Int, totalTasks: Int, streakDays: Int) async -> String? {
        if appleAI.isAvailable {
            let prompt = buildExecutiveBriefingPrompt(results: results, profile: profile, roadmapProgress: roadmapProgress, completedTasks: completedTasks, totalTasks: totalTasks, streakDays: streakDays)
            if let response = await appleAI.generate(prompt: prompt, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.generateExecutiveBriefing(results: results, profile: profile, roadmapProgress: roadmapProgress, completedTasks: completedTasks, totalTasks: totalTasks, streakDays: streakDays)
    }

    func chatConversation(messages: [GroqChatMessage], systemPrompt: String) async -> String? {
        if appleAI.isAvailable {
            let tuples = messages.map { (role: $0.role, content: $0.content) }
            if let response = await appleAI.chatConversation(messages: tuples, systemPrompt: systemPrompt) {
                return response
            }
        }
        return await groq.chatConversation(messages: messages, systemPrompt: systemPrompt)
    }

    // MARK: - Prompt Builders

    private func buildExecutiveSummaryPrompt(result: AssessmentResult, profile: UserProfile) -> String {
        let strongest = result.strongestCategory?.category.rawValue ?? "unknown"
        let strongestScore = Int(result.strongestCategory?.normalizedScore ?? 0)
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
        let score = Int(result.overallScore)
        let level = result.level.rawValue
        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")

        return """
        Generate a concise, insightful executive summary (3-4 sentences) for this user's assessment results.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)
        Overall Pulse Score: \(score)/100 (Level: \(level))
        Strongest: \(strongest) (\(strongestScore)%)
        Weakest: \(weakest) (\(weakestScore)%)
        All scores: \(categoryBreakdown)

        Write in second person ("Your..."). Be direct, actionable, and specific to their role and industry. No generic advice. Reference specific score numbers and categories. Tone: professional, confident, slightly urgent if scores are low.
        """
    }

    private func buildDailyTipPrompt(result: AssessmentResult, profile: UserProfile, streakDays: Int) -> String {
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
        let score = Int(result.overallScore)

        return """
        Generate one short, punchy coaching tip (2-3 sentences max) for today.

        User: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Pulse Score: \(score)/100
        Weakest area: \(weakest) at \(weakestScore)%
        Current streak: \(streakDays) days

        Make it specific, actionable, and something they can do in under 10 minutes today. Reference their specific weak area. Be motivating but not cheesy.
        """
    }

    private func buildWeeklyInsightsPrompt(result: AssessmentResult, profile: UserProfile, completedTasks: Int, totalTasks: Int) -> String {
        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")

        return """
        Generate exactly 3 personalized weekly insights as a JSON array of strings.

        User: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Pulse Score: \(Int(result.overallScore))/100
        Scores: \(categoryBreakdown)
        Roadmap progress: \(completedTasks)/\(totalTasks) tasks completed

        Each insight should be 1-2 sentences, specific to their profile, and reference actual score data. Focus on patterns, opportunities, and momentum. Return ONLY a JSON array like: ["insight 1", "insight 2", "insight 3"]
        """
    }

    private func buildAnswerAnalysisPrompt(result: AssessmentResult, profile: UserProfile) -> String {
        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")
        let strongest = result.strongestCategory?.category.rawValue ?? "unknown"
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"

        return """
        Analyze the PATTERNS in this user's assessment results — don't just restate scores. Look for non-obvious connections between categories.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)
        Scores: \(categoryBreakdown)
        Strongest: \(strongest)
        Weakest: \(weakest)

        Provide 2-3 pattern observations. Example: "Your Leadership score is strong but Team & Culture is low — this often signals strong vision but delegation challenges." Be specific, insightful, and non-obvious. 3-4 sentences total.
        """
    }

    private func buildProgressNarrativePrompt(oldResult: AssessmentResult, newResult: AssessmentResult, profile: UserProfile, completedTasks: Int) -> String {
        let improvements = AssessmentCategory.allCases.compactMap { cat -> String? in
            let oldScore = oldResult.categoryScores.first(where: { $0.category == cat })?.normalizedScore ?? 0
            let newScore = newResult.categoryScores.first(where: { $0.category == cat })?.normalizedScore ?? 0
            let delta = Int(newScore - oldScore)
            guard delta != 0 else { return nil }
            return "\(cat.rawValue): \(delta > 0 ? "+" : "")\(delta)"
        }.joined(separator: ", ")

        return """
        Generate a progress narrative (3-4 sentences) comparing two assessments.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Previous score: \(Int(oldResult.overallScore))/100
        New score: \(Int(newResult.overallScore))/100
        Category changes: \(improvements)
        Tasks completed between assessments: \(completedTasks)

        Narrate their journey — what improved, what regressed, and hypothesize why based on the data. Be specific and encouraging where warranted, honest where not. Second person.
        """
    }

    private func buildWeeklyRecapPrompt(weekNumber: Int, completedTasks: Int, totalTasks: Int, result: AssessmentResult, profile: UserProfile, streakDays: Int) -> String {
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
        let completionRate = totalTasks > 0 ? Int(Double(completedTasks) / Double(totalTasks) * 100) : 0
        let projectedImprovement = min(15, max(2, completedTasks * 2))

        return """
        Generate a concise weekly recap (3-4 sentences) for a user completing Week \(weekNumber) of their 12-week roadmap.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Pulse Score: \(Int(result.overallScore))/100
        Tasks completed this week: \(completedTasks)/\(totalTasks) (\(completionRate)%)
        Weakest area: \(weakest) at \(weakestScore)%
        Current streak: \(streakDays) days
        Projected score improvement: ~\(projectedImprovement) points if pace continues

        Include: what they accomplished, projected score improvement based on task completion, and one specific focus for next week. Be encouraging but data-driven. Second person.
        """
    }

    private func buildExecutiveBriefingPrompt(results: [AssessmentResult], profile: UserProfile, roadmapProgress: Double, completedTasks: Int, totalTasks: Int, streakDays: Int) -> String {
        let trajectory = results.count >= 2
            ? "Score trajectory: \(results.map { "\(Int($0.overallScore))" }.joined(separator: " → "))"
            : "Single assessment: \(Int(results.last?.overallScore ?? 0))"

        let categoryTrends = results.last?.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ") ?? "N/A"

        return """
        Generate an executive briefing summary (5-7 sentences) suitable for a quarterly business review.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)
        \(trajectory)
        Current category scores: \(categoryTrends)
        Roadmap progress: \(Int(roadmapProgress * 100))% (\(completedTasks)/\(totalTasks) tasks)
        Engagement streak: \(streakDays) days
        Total assessments: \(results.count)

        Write in a professional, McKinsey-style tone. Include: overall trajectory analysis, key strengths, critical gaps requiring attention, projected outcomes if current pace continues, and one strategic recommendation. Use specific numbers throughout. This should read like an executive summary a consultant would present.
        """
    }
}
