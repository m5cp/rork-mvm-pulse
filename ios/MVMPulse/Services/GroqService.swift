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
