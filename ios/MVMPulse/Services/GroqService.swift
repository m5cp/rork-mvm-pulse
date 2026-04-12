import Foundation

nonisolated struct GroqChatMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct GroqRequest: Codable, Sendable {
    let model: String
    let messages: [GroqChatMessage]
    let temperature: Double
    let max_tokens: Int
}

nonisolated struct GroqResponse: Codable, Sendable {
    let choices: [GroqChoice]
}

nonisolated struct GroqChoice: Codable, Sendable {
    let message: GroqChatMessage
}

@Observable
final class GroqService {
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    private let model = "llama-3.3-70b-versatile"

    private var apiKey: String {
        Config.EXPO_PUBLIC_GROQ_API_KEY
    }

    var isAvailable: Bool {
        !apiKey.isEmpty
    }

    func generateExecutiveSummary(result: AssessmentResult, profile: UserProfile) async -> String? {
        guard isAvailable else { return nil }

        let strongest = result.strongestCategory?.category.rawValue ?? "unknown"
        let strongestScore = Int(result.strongestCategory?.normalizedScore ?? 0)
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
        let score = Int(result.overallScore)
        let level = result.level.rawValue

        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")

        let prompt = """
        You are MVM Pulse, a premium business and life health diagnostic tool. Generate a concise, insightful executive summary (3-4 sentences) for this user's assessment results.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)
        Overall Pulse Score: \(score)/100 (Level: \(level))
        Strongest: \(strongest) (\(strongestScore)%)
        Weakest: \(weakest) (\(weakestScore)%)
        All scores: \(categoryBreakdown)

        Write in second person ("Your..."). Be direct, actionable, and specific to their role and industry. No generic advice. Reference specific score numbers and categories. Tone: professional, confident, slightly urgent if scores are low.
        """

        return await chat(prompt: prompt)
    }

    func generateCategoryInsight(category: AssessmentCategory, score: Double, profile: UserProfile) async -> String? {
        guard isAvailable else { return nil }

        let prompt = """
        You are MVM Pulse, a business diagnostics AI. Generate a personalized 2-sentence insight for this category score.

        Category: \(category.rawValue)
        Score: \(Int(score))%
        User: \(profile.role.rawValue) in \(profile.industry.rawValue)

        Be specific to their role and industry. Reference actionable next steps. No fluff.
        """

        return await chat(prompt: prompt)
    }

    func generateDailyCoachingTip(result: AssessmentResult, profile: UserProfile, streakDays: Int) async -> String? {
        guard isAvailable else { return nil }

        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
        let score = Int(result.overallScore)

        let prompt = """
        You are MVM Pulse, an AI business coach. Generate one short, punchy coaching tip (2-3 sentences max) for today.

        User: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Pulse Score: \(score)/100
        Weakest area: \(weakest) at \(weakestScore)%
        Current streak: \(streakDays) days

        Make it specific, actionable, and something they can do in under 10 minutes today. Reference their specific weak area. Be motivating but not cheesy.
        """

        return await chat(prompt: prompt)
    }

    func generateWeeklyInsights(result: AssessmentResult, profile: UserProfile, completedTasks: Int, totalTasks: Int) async -> [String]? {
        guard isAvailable else { return nil }

        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")

        let prompt = """
        You are MVM Pulse, an AI business diagnostics coach. Generate exactly 3 personalized weekly insights as a JSON array of strings.

        User: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Pulse Score: \(Int(result.overallScore))/100
        Scores: \(categoryBreakdown)
        Roadmap progress: \(completedTasks)/\(totalTasks) tasks completed

        Each insight should be 1-2 sentences, specific to their profile, and reference actual score data. Focus on patterns, opportunities, and momentum. Return ONLY a JSON array like: ["insight 1", "insight 2", "insight 3"]
        """

        guard let response = await chat(prompt: prompt) else { return nil }
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = trimmed.data(using: .utf8),
           let insights = try? JSONDecoder().decode([String].self, from: data) {
            return insights
        }
        return [response]
    }

    func chatConversation(messages: [GroqChatMessage], systemPrompt: String) async -> String? {
        guard isAvailable else { return nil }
        guard let url = URL(string: baseURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var allMessages = [GroqChatMessage(role: "system", content: systemPrompt)]
        allMessages.append(contentsOf: messages)

        let body = GroqRequest(
            model: model,
            messages: allMessages,
            temperature: 0.7,
            max_tokens: 800
        )

        guard let httpBody = try? JSONEncoder().encode(body) else { return nil }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }
            let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
            return groqResponse.choices.first?.message.content
        } catch {
            return nil
        }
    }

    func generateAnswerAnalysis(result: AssessmentResult, profile: UserProfile) async -> String? {
        guard isAvailable else { return nil }

        let categoryBreakdown = result.categoryScores
            .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
            .joined(separator: ", ")

        let strongest = result.strongestCategory?.category.rawValue ?? "unknown"
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"

        let prompt = """
        You are MVM Pulse, a premium business diagnostics AI. Analyze the PATTERNS in this user's assessment results — don't just restate scores. Look for non-obvious connections between categories.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)
        Scores: \(categoryBreakdown)
        Strongest: \(strongest)
        Weakest: \(weakest)

        Provide 2-3 pattern observations. Example: "Your Leadership score is strong but Team & Culture is low — this often signals strong vision but delegation challenges." Be specific, insightful, and non-obvious. 3-4 sentences total.
        """

        return await chat(prompt: prompt)
    }

    func generateCheckInReflection(mood: String, moodHistory: String, result: AssessmentResult?, profile: UserProfile) async -> String? {
        guard isAvailable else { return nil }

        let scoreContext: String
        if let result {
            let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
            let weakestScore = Int(result.weakestCategory?.normalizedScore ?? 0)
            scoreContext = "Pulse Score: \(Int(result.overallScore))/100. Weakest area: \(weakest) at \(weakestScore)%."
        } else {
            scoreContext = "No assessment completed yet."
        }

        let prompt = """
        You are MVM Pulse, an AI coach. The user just logged their mood as "\(mood)". Recent mood trend: \(moodHistory). \(scoreContext)
        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue)

        Write a brief, empathetic 2-sentence reflection connecting their mood to their business context. If mood is declining, gently suggest it may be systemic. If improving, reinforce what's working. Be warm but not patronizing.
        """

        return await chat(prompt: prompt)
    }

    func generateProgressNarrative(oldResult: AssessmentResult, newResult: AssessmentResult, profile: UserProfile, completedTasks: Int) async -> String? {
        guard isAvailable else { return nil }

        let improvements = AssessmentCategory.allCases.compactMap { cat -> String? in
            let oldScore = oldResult.categoryScores.first(where: { $0.category == cat })?.normalizedScore ?? 0
            let newScore = newResult.categoryScores.first(where: { $0.category == cat })?.normalizedScore ?? 0
            let delta = Int(newScore - oldScore)
            guard delta != 0 else { return nil }
            return "\(cat.rawValue): \(delta > 0 ? "+" : "")\(delta)"
        }.joined(separator: ", ")

        let prompt = """
        You are MVM Pulse, a premium diagnostics AI. Generate a progress narrative (3-4 sentences) comparing two assessments.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue)
        Previous score: \(Int(oldResult.overallScore))/100
        New score: \(Int(newResult.overallScore))/100
        Category changes: \(improvements)
        Tasks completed between assessments: \(completedTasks)

        Narrate their journey — what improved, what regressed, and hypothesize why based on the data. Be specific and encouraging where warranted, honest where not. Second person.
        """

        return await chat(prompt: prompt)
    }

    func generateCategoryQA(category: AssessmentCategory, score: Double, question: String, profile: UserProfile) async -> String? {
        guard isAvailable else { return nil }

        let prompt = """
        You are MVM Pulse, an expert business diagnostics coach. The user is asking about their \(category.rawValue) score of \(Int(score))%.

        Profile: \(profile.role.rawValue) in \(profile.industry.rawValue), company size: \(profile.companySize.rawValue)

        Their question: \(question)

        Answer in 2-4 sentences. Be specific to their industry and role. Give actionable advice, not theory. Reference their score when relevant.
        """

        return await chat(prompt: prompt)
    }

    private func chat(prompt: String) async -> String? {
        guard let url = URL(string: baseURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GroqRequest(
            model: model,
            messages: [
                GroqChatMessage(role: "system", content: "You are MVM Pulse, a premium AI-powered business and life health diagnostic assistant. Be concise, direct, and insightful."),
                GroqChatMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 500
        )

        guard let httpBody = try? JSONEncoder().encode(body) else { return nil }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return nil }
            let groqResponse = try JSONDecoder().decode(GroqResponse.self, from: data)
            return groqResponse.choices.first?.message.content
        } catch {
            return nil
        }
    }
}
