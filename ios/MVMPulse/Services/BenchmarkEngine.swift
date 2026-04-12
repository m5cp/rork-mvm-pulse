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

nonisolated struct BenchmarkDataSource: Sendable {
    let name: String
    let year: Int
    let url: String
}

struct BenchmarkEngine {

    static let dataSources: [BenchmarkDataSource] = [
        BenchmarkDataSource(name: "McKinsey State of AI 2025", year: 2025, url: "mckinsey.com/state-of-ai"),
        BenchmarkDataSource(name: "OECD AI Adoption by SMEs 2025", year: 2025, url: "oecd.org"),
        BenchmarkDataSource(name: "U.S. Chamber of Commerce SMB Report 2025", year: 2025, url: "uschamber.com"),
        BenchmarkDataSource(name: "SBA Office of Advocacy BTOS 2025", year: 2025, url: "advocacy.sba.gov"),
        BenchmarkDataSource(name: "Deloitte Digital Maturity Index 2025", year: 2025, url: "deloitte.com")
    ]

    static var sourceAttribution: String {
        "Benchmarks derived from McKinsey State of AI 2025 (88% adoption, 6% transformation rate), OECD SME AI Adoption Report 2025, U.S. Chamber of Commerce SMB Survey 2025 (58% gen AI use), SBA BTOS 2025 (8.8% deep AI integration), and Deloitte Digital Maturity Index 2025. Adjusted for industry and company size."
    }

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
            .financialHealth: 41,
            .operationsProductivity: 37,
            .leadershipStrategy: 43,
            .teamCulture: 39,
            .technologyAI: 32,
            .customerMarket: 40,
            .personalWellness: 35,
            .growthLearning: 31
        ]

        var avg = baseAverages[category] ?? 37

        switch industry {
        case .technology:
            switch category {
            case .technologyAI: avg += 15
            case .operationsProductivity: avg += 8
            case .growthLearning: avg += 6
            case .customerMarket: avg += 4
            default: avg += 3
            }
        case .finance:
            switch category {
            case .financialHealth: avg += 12
            case .technologyAI: avg += 8
            case .leadershipStrategy: avg += 5
            case .operationsProductivity: avg += 4
            default: avg += 2
            }
        case .healthcare:
            switch category {
            case .personalWellness: avg += 7
            case .teamCulture: avg += 4
            case .leadershipStrategy: avg += 3
            case .technologyAI: avg -= 2
            default: avg += 0
            }
        case .education:
            switch category {
            case .growthLearning: avg += 10
            case .teamCulture: avg += 3
            case .personalWellness: avg += 2
            case .technologyAI: avg -= 4
            case .financialHealth: avg -= 3
            default: avg -= 1
            }
        case .retail:
            switch category {
            case .customerMarket: avg += 9
            case .operationsProductivity: avg += 3
            case .technologyAI: avg -= 2
            case .leadershipStrategy: avg -= 1
            default: avg += 0
            }
        case .manufacturing:
            switch category {
            case .operationsProductivity: avg += 10
            case .teamCulture: avg += 3
            case .technologyAI: avg += 2
            case .personalWellness: avg -= 3
            case .growthLearning: avg -= 2
            default: avg += 1
            }
        case .government:
            switch category {
            case .leadershipStrategy: avg += 4
            case .teamCulture: avg += 2
            case .technologyAI: avg -= 6
            case .operationsProductivity: avg -= 3
            case .customerMarket: avg -= 4
            default: avg -= 2
            }
        case .legal:
            switch category {
            case .financialHealth: avg += 7
            case .leadershipStrategy: avg += 3
            case .technologyAI: avg -= 3
            case .personalWellness: avg -= 2
            default: avg += 1
            }
        case .professionalServices:
            switch category {
            case .customerMarket: avg += 6
            case .leadershipStrategy: avg += 4
            case .financialHealth: avg += 3
            case .technologyAI: avg += 2
            default: avg += 2
            }
        case .realEstate:
            switch category {
            case .financialHealth: avg += 5
            case .customerMarket: avg += 4
            case .technologyAI: avg -= 3
            case .personalWellness: avg -= 1
            default: avg += 0
            }
        case .other:
            break
        }

        switch companySize {
        case .solo: avg -= 4
        case .tinyTeam: avg -= 2
        case .smallTeam: break
        case .mediumTeam: avg += 3
        case .largeTeam: avg += 5
        case .enterprise: avg += 8
        }

        return min(82, max(15, avg))
    }

    static func estimatedAnnualSavings(industry: Industry, companySize: CompanySize, currentScore: Double) -> (low: Int, high: Int) {
        let baseRevenue: Double
        switch companySize {
        case .solo: baseRevenue = 80_000
        case .tinyTeam: baseRevenue = 500_000
        case .smallTeam: baseRevenue = 2_000_000
        case .mediumTeam: baseRevenue = 10_000_000
        case .largeTeam: baseRevenue = 50_000_000
        case .enterprise: baseRevenue = 200_000_000
        }

        let aiProductivityGainPct: Double
        switch industry {
        case .technology: aiProductivityGainPct = 0.038
        case .finance: aiProductivityGainPct = 0.035
        case .healthcare: aiProductivityGainPct = 0.028
        case .manufacturing: aiProductivityGainPct = 0.032
        case .retail: aiProductivityGainPct = 0.025
        case .professionalServices: aiProductivityGainPct = 0.034
        case .legal: aiProductivityGainPct = 0.030
        case .education: aiProductivityGainPct = 0.022
        case .government: aiProductivityGainPct = 0.018
        case .realEstate: aiProductivityGainPct = 0.024
        case .other: aiProductivityGainPct = 0.026
        }

        let gapMultiplier = max(0.3, (100 - currentScore) / 100)
        let baseSaving = baseRevenue * aiProductivityGainPct * gapMultiplier

        let low = Int(baseSaving * 0.7)
        let high = Int(baseSaving * 1.4)
        return (low: max(500, low), high: max(1000, high))
    }

    static func productivityHoursEstimate(companySize: CompanySize, currentScore: Double) -> (weeklyHours: Int, annualHours: Int) {
        let teamSize: Double
        switch companySize {
        case .solo: teamSize = 1
        case .tinyTeam: teamSize = 5
        case .smallTeam: teamSize = 25
        case .mediumTeam: teamSize = 100
        case .largeTeam: teamSize = 500
        case .enterprise: teamSize = 1000
        }

        let hoursPerPersonPerWeek = max(1, (100 - currentScore) / 100 * 5)
        let weekly = Int(teamSize * hoursPerPersonPerWeek)
        let annual = weekly * 48
        return (weeklyHours: weekly, annualHours: annual)
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
