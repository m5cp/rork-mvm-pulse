import SwiftUI

enum PulseTheme {
    static let primaryTeal = Color(red: 9/255, green: 119/255, blue: 112/255)
    static let darkNavy = Color(red: 7/255, green: 16/255, blue: 30/255)
    static let surfaceDark = Color(red: 17/255, green: 17/255, blue: 17/255)
    static let lightSurface = Color(red: 246/255, green: 246/255, blue: 246/255)
    static let bodyText = Color(red: 89/255, green: 89/255, blue: 89/255)
    static let headingText = Color(red: 17/255, green: 17/255, blue: 17/255)

    static func scoreColor(for level: ScoreLevel) -> Color {
        switch level {
        case .critical: .red
        case .atRisk: .orange
        case .developing: primaryTeal
        case .strong: .green
        case .elite: .green
        }
    }

    static func scoreColor(for score: Double) -> Color {
        scoreColor(for: ScoreLevel.from(score: score))
    }

    static func categoryColor(for category: AssessmentCategory) -> Color {
        switch category {
        case .financialHealth: Color(red: 34/255, green: 139/255, blue: 87/255)
        case .operationsProductivity: Color(red: 59/255, green: 130/255, blue: 246/255)
        case .leadershipStrategy: Color(red: 124/255, green: 58/255, blue: 237/255)
        case .teamCulture: Color(red: 236/255, green: 117/255, blue: 44/255)
        case .technologyAI: Color(red: 6/255, green: 182/255, blue: 212/255)
        case .customerMarket: Color(red: 239/255, green: 68/255, blue: 68/255)
        case .personalWellness: Color(red: 236/255, green: 72/255, blue: 153/255)
        case .growthLearning: Color(red: 168/255, green: 136/255, blue: 42/255)
        }
    }

    static var cardBackground: Color {
        Color(.secondarySystemGroupedBackground)
    }

    static var groupedBackground: Color {
        Color(.systemGroupedBackground)
    }
}
