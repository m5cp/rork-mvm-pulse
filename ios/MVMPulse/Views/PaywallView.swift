import SwiftUI
import RevenueCat

struct PaywallView: View {
    var store: StoreViewModel
    @State private var selectedPackageId: String?
    @Environment(\.dismiss) private var dismiss

    private var packages: [Package] {
        store.offerings?.current?.availablePackages ?? []
    }

    private var selectedPackage: Package? {
        packages.first(where: { $0.identifier == selectedPackageId })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                headerSection
                comparisonTable
                if store.isLoading {
                    ProgressView()
                        .padding(.vertical, 20)
                } else if !packages.isEmpty {
                    planSelector
                    purchaseButton
                    restoreButton
                } else {
                    ContentUnavailableView("Unable to Load Plans", systemImage: "exclamationmark.triangle", description: Text("Please check your connection and try again."))
                        .padding(.vertical, 20)
                }
                legalLinks
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
        .alert("Error", isPresented: .init(
            get: { store.error != nil },
            set: { if !$0 { store.error = nil } }
        )) {
            Button("OK") { store.error = nil }
        } message: {
            Text(store.error ?? "")
        }
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        .onAppear {
            if selectedPackageId == nil, let annual = packages.first(where: { $0.packageType == .annual }) {
                selectedPackageId = annual.identifier
            } else if selectedPackageId == nil, let first = packages.first {
                selectedPackageId = first.identifier
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

            Text("Industry benchmarking, AI strategy sessions, executive briefings, and a personalized 12-week roadmap.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                premiumHighlight(icon: "chart.bar.xaxis", label: "Benchmarks")
                premiumHighlight(icon: "sparkles", label: "AI Coach")
                premiumHighlight(icon: "doc.text.fill", label: "Reports")
            }
            .padding(.top, 4)
        }
    }

    private func premiumHighlight(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PulseTheme.primaryTeal)
            Text(label)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
            comparisonRow("Industry benchmarking", free: false, premium: true)
            comparisonRow("12-week personalized roadmap", free: false, premium: true)
            comparisonRow("PDF diagnostic report", free: false, premium: true)
            comparisonRow("Score history & trends", free: false, premium: true)
            comparisonRow("All share card styles", free: false, premium: true)
            comparisonRow("Reassessment insights", free: false, premium: true)
            comparisonRow("Streak tracking & milestones", free: false, premium: true)
            comparisonRow("Weekly check-in recaps", free: false, premium: true)
            comparisonRow("Quarterly executive briefing", free: false, premium: true)

            Divider().padding(.vertical, 4)

            aiUsageSection
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var aiUsageSection: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(PulseTheme.primaryTeal)
                    Text("AI Features")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("Free")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 50)

                Text("Premium")
                    .font(.caption2.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
                    .frame(width: 65)
            }
            .padding(.bottom, 4)

            aiLimitRow("AI Coach chat", freeLabel: "\u{2014}", premiumLabel: "50/day")
            aiLimitRow("AI insights", freeLabel: "5/day", premiumLabel: "25/day")
            aiLimitRow("Category Q&A", freeLabel: "2/day", premiumLabel: "15/day")
        }
    }

    private func aiLimitRow(_ feature: String, freeLabel: String, premiumLabel: String) -> some View {
        HStack {
            Text(feature)
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(freeLabel)
                .font(.caption2.bold())
                .foregroundStyle(freeLabel == "\u{2014}" ? Color(.tertiaryLabel) : .secondary)
                .frame(width: 50)

            Text(premiumLabel)
                .font(.caption2.bold())
                .foregroundStyle(PulseTheme.primaryTeal)
                .frame(width: 65)
        }
        .padding(.vertical, 3)
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
            ForEach(packages, id: \.identifier) { package in
                let isSelected = selectedPackageId == package.identifier
                let isAnnual = package.packageType == .annual

                Button {
                    selectedPackageId = package.identifier
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(package.storeProduct.localizedTitle)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)

                                if isAnnual {
                                    Text("BEST VALUE")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(PulseTheme.primaryTeal)
                                        .clipShape(Capsule())
                                }
                            }

                            if let intro = package.storeProduct.introductoryDiscount {
                                Text("\(intro.subscriptionPeriod.value)-\(unitLabel(intro.subscriptionPeriod.unit)) free trial")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(package.storeProduct.localizedDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        Text(package.storeProduct.localizedPriceString)
                            .font(.subheadline.bold())
                            .foregroundStyle(isSelected ? PulseTheme.primaryTeal : .primary)
                    }
                    .padding(16)
                    .background(
                        isSelected
                            ? PulseTheme.primaryTeal.opacity(0.08)
                            : Color(.secondarySystemGroupedBackground)
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(isSelected ? PulseTheme.primaryTeal : .clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            guard let pkg = selectedPackage else { return }
            Task { await store.purchase(package: pkg) }
        } label: {
            Group {
                if store.isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(purchaseButtonTitle)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(PulseTheme.primaryTeal)
        .disabled(store.isPurchasing || selectedPackage == nil)
    }

    private var purchaseButtonTitle: String {
        guard let pkg = selectedPackage else { return "Subscribe Now" }
        if pkg.storeProduct.introductoryDiscount != nil {
            return "Start Free Trial"
        }
        return "Subscribe Now"
    }

    private var restoreButton: some View {
        Button {
            Task { await store.restore() }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .disabled(store.isPurchasing)
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            if let privacyURL = URL(string: "https://m5cairo.com/privacy") {
                Link("Privacy Policy", destination: privacyURL)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            Text("\u{00B7}")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let termsURL = URL(string: "https://m5cairo.com/terms") {
                Link("Terms of Use", destination: termsURL)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            Text("\u{00B7}")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if let eulaURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                Link("EULA", destination: eulaURL)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.primaryTeal)
            }
        }
    }

    private var legalText: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    private func unitLabel(_ unit: SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return ""
        }
    }
}
