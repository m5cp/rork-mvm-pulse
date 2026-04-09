import Foundation

nonisolated enum AssessmentCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    var id: String { rawValue }
    case financialHealth = "Financial Health"
    case operationsProductivity = "Operations & Productivity"
    case leadershipStrategy = "Leadership & Strategy"
    case teamCulture = "Team & Culture"
    case technologyAI = "Technology & AI Readiness"
    case customerMarket = "Customer & Market"
    case personalWellness = "Personal Wellness"
    case growthLearning = "Growth & Learning"

    var weight: Double {
        switch self {
        case .financialHealth: 1.4
        case .operationsProductivity: 1.3
        case .leadershipStrategy: 1.2
        case .teamCulture: 1.0
        case .technologyAI: 1.1
        case .customerMarket: 1.1
        case .personalWellness: 0.9
        case .growthLearning: 0.8
        }
    }

    var icon: String {
        switch self {
        case .financialHealth: "dollarsign.circle.fill"
        case .operationsProductivity: "gearshape.2.fill"
        case .leadershipStrategy: "flag.fill"
        case .teamCulture: "person.3.fill"
        case .technologyAI: "cpu.fill"
        case .customerMarket: "chart.line.uptrend.xyaxis"
        case .personalWellness: "heart.fill"
        case .growthLearning: "book.fill"
        }
    }
}

nonisolated struct AssessmentQuestion: Codable, Identifiable, Sendable {
    let id: String
    let category: AssessmentCategory
    let text: String
    let options: [AnswerOption]
    let isCore: Bool
}

nonisolated enum AssessmentMode: String, Codable, Sendable {
    case quick
    case full
    case deepDive
}

nonisolated struct AnswerOption: Codable, Identifiable, Sendable {
    let id: String
    let text: String
    let score: Int
}

nonisolated struct AssessmentResponse: Codable, Sendable {
    let questionId: String
    let selectedOptionId: String
    let score: Int
}

nonisolated struct CategoryScore: Codable, Identifiable, Sendable {
    var id: String { category.rawValue }
    let category: AssessmentCategory
    let rawScore: Int
    let normalizedScore: Double
}

nonisolated enum ScoreLevel: String, Codable, Sendable {
    case critical = "Critical"
    case atRisk = "At Risk"
    case developing = "Developing"
    case strong = "Strong"
    case elite = "Elite"

    static func from(score: Double) -> ScoreLevel {
        switch score {
        case 0..<20: return .critical
        case 20..<35: return .atRisk
        case 35..<50: return .developing
        case 50..<65: return .strong
        default: return .elite
        }
    }
}

nonisolated struct AssessmentResult: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    let overallScore: Double
    let level: ScoreLevel
    let categoryScores: [CategoryScore]
    let responses: [AssessmentResponse]
    let mode: AssessmentMode

    var isRefined: Bool {
        mode == .full || mode == .deepDive
    }

    var unrefinedCategories: [AssessmentCategory] {
        let answeredIds = Set(responses.map(\.questionId))
        return AssessmentCategory.allCases.filter { cat in
            let allQs = QuestionBank.questions(for: cat)
            let answered = allQs.filter { answeredIds.contains($0.id) }
            return answered.count < allQs.count
        }
    }

    var strongestCategory: CategoryScore? {
        categoryScores.max(by: { $0.normalizedScore < $1.normalizedScore })
    }

    var weakestCategory: CategoryScore? {
        categoryScores.min(by: { $0.normalizedScore < $1.normalizedScore })
    }

    var twoWeakestCategories: [AssessmentCategory] {
        Array(categoryScores.sorted(by: { $0.normalizedScore < $1.normalizedScore }).prefix(2).map(\.category))
    }
}
