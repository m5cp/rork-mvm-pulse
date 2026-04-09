import SwiftUI

struct GoalSettingView: View {
    let storage: StorageService
    @State private var targetScore: Double
    @State private var targetDate: Date
    @State private var saved: Bool = false
    @Environment(\.dismiss) private var dismiss

    init(storage: StorageService) {
        self.storage = storage
        let existing = storage.goalData
        _targetScore = State(initialValue: existing?.targetScore ?? 65)
        _targetDate = State(initialValue: existing?.targetDate ?? Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date())
    }

    private var currentScore: Double {
        storage.latestResult?.overallScore ?? 0
    }

    private var pointsNeeded: Int {
        max(0, Int(targetScore) - Int(currentScore))
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Set Your Goal")
                    .font(.title2.bold())
                Text("Where do you want your Pulse Score to be?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 10)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: targetScore / 100)
                        .stroke(PulseTheme.primaryTeal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(Int(targetScore))")
                            .font(.system(size: 36, weight: .heavy))
                            .contentTransition(.numericText())

                        Text("TARGET")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                }

                VStack(spacing: 4) {
                    Slider(value: $targetScore, in: max(currentScore + 1, 20)...100, step: 1)
                        .tint(PulseTheme.primaryTeal)
                        .sensoryFeedback(.selection, trigger: Int(targetScore))

                    HStack {
                        Text("Current: \(Int(currentScore))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text("+\(pointsNeeded) points needed")
                            .font(.caption2.bold())
                            .foregroundStyle(PulseTheme.primaryTeal)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 12) {
                Text("Target Date")
                    .font(.subheadline.bold())

                DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()

                let days = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
                Text("\(days) days from now")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))

            Spacer()

            Button {
                storage.goalData = GoalData(targetScore: targetScore, targetDate: targetDate)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    saved = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(0.8))
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    if saved {
                        Image(systemName: "checkmark")
                            .font(.subheadline.bold())
                    }
                    Text(saved ? "Saved!" : "Set Goal")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(saved ? .green : PulseTheme.primaryTeal)
            .disabled(saved)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
