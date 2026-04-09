import SwiftUI

struct ReassessmentCompareView: View {
    let oldResult: AssessmentResult
    let newResult: AssessmentResult
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                scoreComparison
                categoryComparison
                ctaSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { onDismiss() }
            }
        }
    }

    private var scoreComparison: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Previous")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .stroke(PulseTheme.scoreColor(for: oldResult.overallScore).opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: oldResult.overallScore / 100)
                        .stroke(PulseTheme.scoreColor(for: oldResult.overallScore), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(oldResult.overallScore))")
                        .font(.title2.bold())
                }
                .frame(width: 100, height: 100)

                Text(oldResult.level.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(PulseTheme.scoreColor(for: oldResult.overallScore))
            }

            VStack(spacing: 4) {
                Image(systemName: delta > 0 ? "arrow.right" : delta < 0 ? "arrow.right" : "equal")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(deltaText)
                    .font(.subheadline.bold())
                    .foregroundStyle(deltaColor)
            }

            VStack(spacing: 8) {
                Text("Current")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .stroke(PulseTheme.scoreColor(for: newResult.overallScore).opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: newResult.overallScore / 100)
                        .stroke(PulseTheme.scoreColor(for: newResult.overallScore), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(newResult.overallScore))")
                        .font(.title2.bold())
                }
                .frame(width: 100, height: 100)

                Text(newResult.level.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(PulseTheme.scoreColor(for: newResult.overallScore))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var categoryComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Changes")
                .font(.headline)

            ForEach(AssessmentCategory.allCases, id: \.self) { category in
                let oldScore = oldResult.categoryScores.first(where: { $0.category == category })?.normalizedScore ?? 0
                let newScore = newResult.categoryScores.first(where: { $0.category == category })?.normalizedScore ?? 0
                let catDelta = newScore - oldScore

                HStack(spacing: 10) {
                    Image(systemName: category.icon)
                        .font(.caption)
                        .foregroundStyle(PulseTheme.primaryTeal)
                        .frame(width: 24)

                    Text(category.rawValue)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)

                    Text("\(Int(oldScore))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .trailing)

                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    Text("\(Int(newScore))")
                        .font(.caption.bold())
                        .frame(width: 28, alignment: .trailing)

                    Text(catDelta >= 0 ? "+\(Int(catDelta))" : "\(Int(catDelta))")
                        .font(.caption.bold())
                        .foregroundStyle(catDelta > 0 ? .green : catDelta < 0 ? .red : .secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var ctaSection: some View {
        VStack(spacing: 8) {
            Text("Your roadmap has been updated based on your new results.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var delta: Double {
        newResult.overallScore - oldResult.overallScore
    }

    private var deltaText: String {
        let d = Int(delta)
        if d > 0 { return "+\(d)" }
        if d < 0 { return "\(d)" }
        return "±0"
    }

    private var deltaColor: Color {
        if delta > 0 { return .green }
        if delta < 0 { return .red }
        return .secondary
    }
}
