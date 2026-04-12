import SwiftUI

struct IndustryBenchmarkView: View {
    let result: AssessmentResult
    let storage: StorageService
    @Environment(\.dismiss) private var dismiss

    private var benchmarks: [CategoryBenchmarkResult] {
        BenchmarkEngine.industryBenchmarks(
            result: result,
            industry: storage.userProfile.industry,
            companySize: storage.userProfile.companySize
        )
    }

    private var savings: (low: Int, high: Int) {
        BenchmarkEngine.estimatedAnnualSavings(
            industry: storage.userProfile.industry,
            companySize: storage.userProfile.companySize,
            currentScore: result.overallScore
        )
    }

    private var productivity: (weeklyHours: Int, annualHours: Int) {
        BenchmarkEngine.productivityHoursEstimate(
            companySize: storage.userProfile.companySize,
            currentScore: result.overallScore
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                savingsEstimateCard
                productivityCard

                ForEach(benchmarks, id: \.category) { bm in
                    benchmarkRow(bm)
                }

                dataSourcesCard
                disclaimerText
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Industry Benchmark")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(PulseTheme.primaryTeal)

            Text("How You Compare")
                .font(.title3.bold())

            Text("Your scores vs. the average \(storage.userProfile.industry.rawValue.lowercased()) \(storage.userProfile.role.rawValue.lowercased()) with a \(storage.userProfile.companySize.rawValue) person team.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var savingsEstimateCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.arrow.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                Text("Estimated Productivity Gains")
                    .font(.subheadline.bold())
                Spacer()
            }

            HStack(spacing: 4) {
                Text("$\(formatNumber(savings.low))")
                    .font(.title2.bold())
                    .foregroundStyle(.green)
                Text("\u{2013}")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("$\(formatNumber(savings.high))")
                    .font(.title2.bold())
                    .foregroundStyle(.green)
                Text("/year")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Estimated annual value from closing your readiness gap through AI-driven productivity improvements. Based on \(storage.userProfile.industry.rawValue.lowercased()) benchmarks for \(storage.userProfile.companySize.rawValue)-person teams.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("This represents productivity enhancement \u{2014} not headcount reduction. AI tools can help your team accomplish more, reduce repetitive tasks, and focus on higher-value work.")
                .font(.caption)
                .foregroundStyle(PulseTheme.primaryTeal)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.green.opacity(0.15), lineWidth: 1)
        )
    }

    private var productivityCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.2.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Time Recovered with AI")
                    .font(.subheadline.bold())
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("~\(productivity.weeklyHours)")
                        .font(.title2.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                    Text("hrs/week")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 4) {
                    Text("~\(formatNumber(productivity.annualHours))")
                        .font(.title2.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                    Text("hrs/year")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Estimated team hours recoverable through AI automation and workflow optimization. Time saved can be reinvested into innovation, customer engagement, and strategic initiatives.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func benchmarkRow(_ bm: CategoryBenchmarkResult) -> some View {
        let catColor = PulseTheme.categoryColor(for: bm.category)
        let isAbove = bm.delta >= 0

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: bm.category.icon)
                    .font(.body)
                    .foregroundStyle(catColor)
                    .frame(width: 32, height: 32)
                    .background(catColor.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(bm.category.rawValue)
                        .font(.subheadline.bold())

                    Text(bm.context)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: isAbove ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2.bold())
                        Text("\(isAbove ? "+" : "")\(Int(bm.delta))")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(isAbove ? .green : .orange)
                }
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    MiniProgressBar(value: bm.userScore, color: catColor, height: 6)
                    Text("\(Int(bm.userScore))%")
                        .font(.caption2.bold())
                        .foregroundStyle(catColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Industry Avg")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    MiniProgressBar(value: bm.industryAverage, color: .gray.opacity(0.5), height: 6)
                    Text("\(Int(bm.industryAverage))%")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var dataSourcesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Data Sources")
                    .font(.caption.bold())
            }

            ForEach(BenchmarkEngine.dataSources, id: \.name) { source in
                HStack(spacing: 6) {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.4))
                        .frame(width: 4, height: 4)
                    Text("\(source.name) (\(source.year))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PulseTheme.primaryTeal.opacity(0.04))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var disclaimerText: some View {
        Text("Benchmarks are estimated from publicly available research including McKinsey State of AI 2025, OECD SME reports, and U.S. Chamber of Commerce surveys. Adjusted for your industry and team size. Savings estimates represent productivity enhancement potential \u{2014} not cost reduction through workforce changes. Individual results will vary.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
