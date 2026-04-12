import Foundation

nonisolated struct TeamMember: Codable, Identifiable, Sendable {
    let id: String
    var name: String
    var email: String
    var role: String
    var invitedDate: Date
    var hasCompleted: Bool
    var categoryScores: [CategoryScore]?
    var overallScore: Double?
    var completedDate: Date?
}

nonisolated struct TeamAssessmentData: Codable, Sendable {
    var members: [TeamMember]
    var teamName: String

    var completedMembers: [TeamMember] {
        members.filter(\.hasCompleted)
    }

    var pendingMembers: [TeamMember] {
        members.filter { !$0.hasCompleted }
    }

    var averageScore: Double? {
        let scores = completedMembers.compactMap(\.overallScore)
        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / Double(scores.count)
    }

    func alignmentGap(for category: AssessmentCategory) -> Double? {
        let scores = completedMembers.compactMap { member in
            member.categoryScores?.first(where: { $0.category == category })?.normalizedScore
        }
        guard scores.count >= 2 else { return nil }
        let maxScore = scores.max() ?? 0
        let minScore = scores.min() ?? 0
        return maxScore - minScore
    }

    func categoryAverage(for category: AssessmentCategory) -> Double? {
        let scores = completedMembers.compactMap { member in
            member.categoryScores?.first(where: { $0.category == category })?.normalizedScore
        }
        guard !scores.isEmpty else { return nil }
        return scores.reduce(0, +) / Double(scores.count)
    }

    static let maxMembers = 5
}
