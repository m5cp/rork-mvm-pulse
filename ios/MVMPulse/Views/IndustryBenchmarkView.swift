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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard

                ForEach(benchmarks, id: \.category) { bm in
                    benchmarkRow(bm)
                }

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

    private var disclaimerText: some View {
        Text("Benchmarks are based on aggregated industry data and general research. Individual results may vary based on specific business context.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }
}
