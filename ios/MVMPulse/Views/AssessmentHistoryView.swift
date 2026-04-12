import SwiftUI

struct AssessmentHistoryView: View {
    let storage: StorageService
    let store: StoreViewModel
    var ai: AIViewModel = AIViewModel()
    @State private var selectedResult: AssessmentResult?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if storage.assessmentResults.isEmpty {
                ContentUnavailableView(
                    "No Assessments Yet",
                    systemImage: "waveform.path.ecg",
                    description: Text("Complete your first assessment to see your history here.")
                )
            } else {
                ForEach(storage.assessmentResults.reversed()) { result in
                    Button {
                        selectedResult = result
                    } label: {
                        historyRow(result: result)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Assessment History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(item: $selectedResult) { result in
            NavigationStack {
                ResultsView(result: result, storage: storage, store: store, ai: ai)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { selectedResult = nil }
                        }
                    }
            }
        }
    }

    private func historyRow(result: AssessmentResult) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(PulseTheme.scoreColor(for: result.overallScore).opacity(0.2), lineWidth: 4)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: result.overallScore / 100)
                    .stroke(PulseTheme.scoreColor(for: result.overallScore), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(result.overallScore))")
                    .font(.caption.bold())
                    .foregroundStyle(PulseTheme.scoreColor(for: result.overallScore))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(result.level.rawValue)
                        .font(.subheadline.bold())

                    Text(modeLabel(result.mode))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(PulseTheme.primaryTeal.opacity(0.1))
                        .clipShape(Capsule())
                }

                Text(result.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let delta = scoreDelta(for: result) {
                    HStack(spacing: 4) {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(delta >= 0 ? "+\(delta)" : "\(delta)")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(delta >= 0 ? .green : .red)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private func modeLabel(_ mode: AssessmentMode) -> String {
        switch mode {
        case .quick: "Quick"
        case .full: "Full"
        case .deepDive: "Refined"
        }
    }

    private func scoreDelta(for result: AssessmentResult) -> Int? {
        guard let index = storage.assessmentResults.firstIndex(where: { $0.id == result.id }),
              index > 0 else { return nil }
        let previous = storage.assessmentResults[index - 1]
        return Int(result.overallScore) - Int(previous.overallScore)
    }
}
