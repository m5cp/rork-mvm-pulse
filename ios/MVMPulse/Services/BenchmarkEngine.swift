import Foundation

struct BenchmarkResult: Sendable {
    let percentile: Int
    let label: String
    let context: String
}

nonisolated struct CategoryBenchmarkResult: Sendable {
    let category: AssessmentCategory
    let userScore: Double
    let industryAverage: Double
    let percentile: Int
    let delta: Double
    let context: String
}

struct BenchmarkEngine {
    static func benchmark(score: Double, role: UserRole, industry: Industry) -> BenchmarkResult {
        let basePercentile = percentileFromScore(score)
        let adjusted = min(99, max(1, basePercentile + roleAdjustment(role) + industryAdjustment(industry)))

        let label: String
        switch adjusted {
        case 0..<25: label = "Below Average"
        case 25..<50: label = "Average"
        case 50..<75: label = "Above Average"
        case 75..<90: label = "Top Quartile"
        default: label = "Top 10%"
        }

        let roleLabel = role.rawValue.lowercased()
        let industryLabel = industry.rawValue.lowercased()
        let context = "You scored higher than \(adjusted)% of \(roleLabel)s in \(industryLabel)."

        return BenchmarkResult(percentile: adjusted, label: label, context: context)
    }

    static func categoryBenchmark(category: AssessmentCategory, score: Double) -> Int {
        let base = percentileFromScore(score)
        let catOffset: Int
        switch category {
        case .technologyAI: catOffset = -3
        case .financialHealth: catOffset = 2
        case .personalWellness: catOffset = -2
        case .growthLearning: catOffset = -1
        default: catOffset = 0
        }
        return min(99, max(1, base + catOffset))
    }

    static func industryBenchmarks(result: AssessmentResult, industry: Industry, companySize: CompanySize) -> [CategoryBenchmarkResult] {
        result.categoryScores.map { cs in
            let avg = industryAverage(for: cs.category, industry: industry, companySize: companySize)
            let pct = categoryBenchmark(category: cs.category, score: cs.normalizedScore)
            let delta = cs.normalizedScore - avg
            let context: String
            if delta > 10 {
                context = "Well above the \(industry.rawValue.lowercased()) average of \(Int(avg))"
            } else if delta > 0 {
                context = "Slightly above the \(industry.rawValue.lowercased()) average of \(Int(avg))"
            } else if delta > -10 {
                context = "Slightly below the \(industry.rawValue.lowercased()) average of \(Int(avg))"
            } else {
                context = "Below the \(industry.rawValue.lowercased()) average of \(Int(avg))"
            }
            return CategoryBenchmarkResult(
                category: cs.category,
                userScore: cs.normalizedScore,
                industryAverage: avg,
                percentile: pct,
                delta: delta,
                context: context
            )
        }
    }

    static func industryAverage(for category: AssessmentCategory, industry: Industry, companySize: CompanySize) -> Double {
        let baseAverages: [AssessmentCategory: Double] = [
            .financialHealth: 42,
            .operationsProductivity: 38,
            .leadershipStrategy: 44,
            .teamCulture: 40,
            .technologyAI: 35,
            .customerMarket: 41,
            .personalWellness: 36,
            .growthLearning: 33
        ]

        var avg = baseAverages[category] ?? 38

        switch industry {
        case .technology: avg += (category == .technologyAI ? 12 : 3)
        case .finance: avg += (category == .financialHealth ? 10 : 2)
        case .healthcare: avg += (category == .personalWellness ? 5 : -1)
        case .education: avg += (category == .growthLearning ? 8 : -2)
        case .retail: avg += (category == .customerMarket ? 7 : -1)
        case .manufacturing: avg += (category == .operationsProductivity ? 8 : 0)
        case .government: avg += (category == .leadershipStrategy ? 3 : -3)
        case .legal: avg += (category == .financialHealth ? 5 : 1)
        case .professionalServices: avg += (category == .customerMarket ? 5 : 2)
        case .realEstate: avg += (category == .financialHealth ? 4 : 0)
        case .other: break
        }

        switch companySize {
        case .solo: avg -= 3
        case .tinyTeam: avg -= 1
        case .smallTeam: break
        case .mediumTeam: avg += 2
        case .largeTeam: avg += 4
        case .enterprise: avg += 6
        }

        return min(85, max(15, avg))
    }

    private static func percentileFromScore(_ score: Double) -> Int {
        switch score {
        case 0..<15: return Int.random(in: 5...15)
        case 15..<25: return Int.random(in: 15...30)
        case 25..<35: return Int.random(in: 28...45)
        case 35..<45: return Int.random(in: 40...58)
        case 45..<55: return Int.random(in: 52...68)
        case 55..<65: return Int.random(in: 65...80)
        case 65..<75: return Int.random(in: 75...88)
        case 75..<85: return Int.random(in: 85...94)
        default: return Int.random(in: 92...99)
        }
    }

    private static func roleAdjustment(_ role: UserRole) -> Int {
        switch role {
        case .businessOwner: return 2
        case .employee: return -1
        case .individual: return 0
        case .student: return -2
        }
    }

    private static func industryAdjustment(_ industry: Industry) -> Int {
        switch industry {
        case .technology: return 1
        case .finance: return 2
        case .healthcare: return 0
        case .education: return -1
        default: return 0
        }
    }
}
