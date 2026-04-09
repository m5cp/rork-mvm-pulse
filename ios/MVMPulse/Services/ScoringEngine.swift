import Foundation

struct ScoringEngine {
    static func calculateCategoryScore(rawScore: Int, questionCount: Int) -> Double {
        let maxPossible = Double(questionCount * 5)
        guard maxPossible > 0 else { return 0 }
        let normalized = Double(rawScore) / maxPossible
        return pow(normalized, 1.25) * 82.0
    }

    static func calculateOverallScore(categoryScores: [CategoryScore]) -> Double {
        let totalWeight = AssessmentCategory.allCases.reduce(0.0) { $0 + $1.weight }
        let weightedSum = categoryScores.reduce(0.0) { sum, cs in
            sum + cs.normalizedScore * cs.category.weight
        }
        let weightedAvg = weightedSum / totalWeight
        let final = min(pow(weightedAvg / 100.0, 1.15) * weightedAvg * 1.02, 100.0)
        return final
    }

    static func processAssessment(responses: [AssessmentResponse], mode: AssessmentMode) -> AssessmentResult {
        var categoryRawScores: [AssessmentCategory: Int] = [:]
        var categoryCounts: [AssessmentCategory: Int] = [:]
        let questions = QuestionBank.allQuestions

        for response in responses {
            guard let question = questions.first(where: { $0.id == response.questionId }) else { continue }
            categoryRawScores[question.category, default: 0] += response.score
            categoryCounts[question.category, default: 0] += 1
        }

        let categoryScores = AssessmentCategory.allCases.map { category in
            let rawScore = categoryRawScores[category] ?? 0
            let count = categoryCounts[category] ?? 0
            let normalized = calculateCategoryScore(rawScore: rawScore, questionCount: count)
            return CategoryScore(category: category, rawScore: rawScore, normalizedScore: normalized)
        }

        let overall = calculateOverallScore(categoryScores: categoryScores)
        let level = ScoreLevel.from(score: overall)

        return AssessmentResult(
            id: UUID().uuidString,
            date: Date(),
            overallScore: overall,
            level: level,
            categoryScores: categoryScores,
            responses: responses,
            mode: mode
        )
    }

    static func refineAssessment(existing: AssessmentResult, newResponses: [AssessmentResponse]) -> AssessmentResult {
        var allResponses = existing.responses
        for response in newResponses {
            if let idx = allResponses.firstIndex(where: { $0.questionId == response.questionId }) {
                allResponses[idx] = response
            } else {
                allResponses.append(response)
            }
        }
        let allAnswered = Set(allResponses.map(\.questionId))
        let totalQuestions = QuestionBank.allQuestions.count
        let newMode: AssessmentMode = allAnswered.count >= totalQuestions ? .full : .deepDive
        return processAssessment(responses: allResponses, mode: newMode)
    }
}
