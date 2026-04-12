import SwiftUI

struct DailyCheckInView: View {
    let storage: StorageService
    let ai: AIViewModel
    let onComplete: () -> Void
    @State private var selectedMood: CheckInMood?
    @State private var note: String = ""
    @State private var appeared: Bool = false
    @State private var submitted: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("How are you feeling about\nyour business today?")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                Text("Quick daily pulse \u{00B7} Takes 5 seconds")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            HStack(spacing: 12) {
                ForEach(CheckInMood.allCases, id: \.rawValue) { mood in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                            selectedMood = mood
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: 36))
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)

                            Text(mood.label)
                                .font(.caption2)
                                .foregroundStyle(selectedMood == mood ? .primary : .tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMood == mood ? PulseTheme.primaryTeal.opacity(0.1) : Color.clear)
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selectedMood == mood ? PulseTheme.primaryTeal.opacity(0.3) : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: selectedMood)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)

            if selectedMood != nil {
                TextField("Quick note (optional)", text: $note)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 10))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if let mood = selectedMood {
                Button {
                    submitCheckIn(mood: mood)
                } label: {
                    HStack(spacing: 8) {
                        if submitted {
                            Image(systemName: "checkmark")
                                .font(.subheadline.bold())
                        }
                        Text(submitted ? "Saved!" : "Log Check-In")
                            .font(.subheadline.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(submitted ? .green : PulseTheme.primaryTeal)
                .disabled(submitted)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if submitted, ai.isAvailable {
                if ai.isLoadingReflection {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Reflecting...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity)
                } else if let reflection = ai.aiCheckInReflection {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(PulseTheme.primaryTeal)
                            .padding(.top, 2)
                        Text(reflection)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(PulseTheme.primaryTeal.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 12))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .onAppear {
            guard !appeared else { return }
            withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func submitCheckIn(mood: CheckInMood) {
        let checkIn = DailyCheckIn(mood: mood, note: note.trimmingCharacters(in: .whitespaces))
        storage.dailyCheckIns.append(checkIn)
        storage.recordActivity()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            submitted = true
        }

        ai.loadCheckInReflection(
            mood: mood,
            recentMoods: storage.dailyCheckIns,
            result: storage.latestResult,
            profile: storage.userProfile
        )

        Task {
            try? await Task.sleep(for: .seconds(4.0))
            onComplete()
        }
    }
}
