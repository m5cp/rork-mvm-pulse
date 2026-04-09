import SwiftUI

struct MilestoneView: View {
    let milestone: StreakMilestone
    @State private var appeared: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(appeared ? 1 : 0.5)

                    Image(systemName: badgeIcon)
                        .font(.system(size: 56))
                        .foregroundStyle(PulseTheme.primaryTeal)
                        .scaleEffect(appeared ? 1 : 0.3)
                        .symbolEffect(.bounce, value: appeared)
                }
                .animation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.6), value: appeared)

                VStack(spacing: 8) {
                    Text(milestone.title)
                        .font(.title.bold())

                    Text(milestoneMessage)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(PulseTheme.primaryTeal)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            appeared = true
        }
    }

    private var badgeIcon: String {
        switch milestone.days {
        case 7: return "flame.fill"
        case 30: return "star.fill"
        case 90: return "trophy.fill"
        default: return "medal.fill"
        }
    }

    private var milestoneMessage: String {
        switch milestone.days {
        case 7: return "Seven consecutive days of action. You are building real momentum."
        case 30: return "A full month of consistent effort. This is where change becomes visible."
        case 90: return "Ninety days of discipline. You have fundamentally shifted your trajectory."
        default: return "You have reached a new milestone. Keep going."
        }
    }
}


