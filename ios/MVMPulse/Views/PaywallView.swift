import SwiftUI

struct PaywallView: View {
    let storage: StorageService
    @State private var selectedPlan: PremiumPlan = .annual
    @State private var isRestoring: Bool = false
    @State private var isPurchasing: Bool = false
    @Environment(\.dismiss) private var dismiss

    enum PremiumPlan {
        case monthly, annual

        var title: String {
            switch self {
            case .monthly: "Monthly"
            case .annual: "Annual"
            }
        }

        var price: String {
            switch self {
            case .monthly: "$9.99/mo"
            case .annual: "$79.99/yr"
            }
        }

        var subtitle: String {
            switch self {
            case .monthly: "Cancel anytime"
            case .annual: "7-day free trial · Save 33%"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                comparisonTable
                planSelector
                purchaseButton
                restoreButton
                legalText
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") { dismiss() }
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)

            Text("Unlock your full diagnostic")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Get detailed analysis, a personalized roadmap, and tools to track your progress over time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            comparisonHeader

            comparisonRow("Full assessment", free: true, premium: true)
            comparisonRow("Overall Pulse Score", free: true, premium: true)
            comparisonRow("Basic category scores", free: true, premium: true)
            comparisonRow("One share card style", free: true, premium: true)

            Divider().padding(.vertical, 4)

            comparisonRow("Detailed category analysis", free: false, premium: true)
            comparisonRow("12-week personalized roadmap", free: false, premium: true)
            comparisonRow("PDF diagnostic report", free: false, premium: true)
            comparisonRow("Score history & trends", free: false, premium: true)
            comparisonRow("All share card styles", free: false, premium: true)
            comparisonRow("Reassessment insights", free: false, premium: true)
            comparisonRow("Streak tracking & milestones", free: false, premium: true)
            comparisonRow("Weekly insights", free: false, premium: true)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var comparisonHeader: some View {
        HStack {
            Text("Feature")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Free")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(width: 50)

            Text("Premium")
                .font(.caption.bold())
                .foregroundStyle(PulseTheme.primaryTeal)
                .frame(width: 65)
        }
        .padding(.bottom, 8)
    }

    private func comparisonRow(_ feature: String, free: Bool, premium: Bool) -> some View {
        HStack {
            Text(feature)
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: free ? "checkmark" : "xmark")
                .font(.caption2.bold())
                .foregroundStyle(free ? .green : Color(.tertiaryLabel))
                .frame(width: 50)

            Image(systemName: premium ? "checkmark" : "xmark")
                .font(.caption2.bold())
                .foregroundStyle(premium ? PulseTheme.primaryTeal : Color(.tertiaryLabel))
                .frame(width: 65)
        }
        .padding(.vertical, 5)
    }

    private var planSelector: some View {
        VStack(spacing: 10) {
            planButton(plan: .annual, recommended: true)
            planButton(plan: .monthly, recommended: false)
        }
    }

    private func planButton(plan: PremiumPlan, recommended: Bool) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(plan.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)

                        if recommended {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(PulseTheme.primaryTeal)
                                .clipShape(Capsule())
                        }
                    }

                    Text(plan.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(plan.price)
                    .font(.subheadline.bold())
                    .foregroundStyle(selectedPlan == plan ? PulseTheme.primaryTeal : .primary)
            }
            .padding(16)
            .background(
                selectedPlan == plan
                    ? PulseTheme.primaryTeal.opacity(0.08)
                    : Color(.secondarySystemGroupedBackground)
            )
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(selectedPlan == plan ? PulseTheme.primaryTeal : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            purchase()
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(selectedPlan == .annual ? "Start Free Trial" : "Subscribe Now")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(PulseTheme.primaryTeal)
        .disabled(isPurchasing || isRestoring)
    }

    private var restoreButton: some View {
        Button {
            restore()
        } label: {
            if isRestoring {
                ProgressView()
            } else {
                Text("Restore Purchases")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .disabled(isPurchasing || isRestoring)
    }

    private var legalText: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    private func purchase() {
        isPurchasing = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            storage.isPremium = true
            isPurchasing = false
            dismiss()
        }
    }

    private func restore() {
        isRestoring = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            isRestoring = false
        }
    }
}
