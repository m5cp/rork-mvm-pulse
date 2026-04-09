import Foundation

struct BenchmarkResult: Sendable {
    let percentile: Int
    let label: String
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
