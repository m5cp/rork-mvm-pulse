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
                trialBanner
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
                premiumServicesTeaser
                legalLinks
                legalText
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Business")
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
            ZStack {
                Circle()
                    .fill(PulseTheme.primaryTeal.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            Text("MVM Pulse Business")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("Enterprise-grade AI diagnostics, team assessments, industry benchmarking, and executive briefings \u{2014} everything you need to lead your AI transformation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                premiumHighlight(icon: "chart.bar.xaxis", label: "Benchmarks")
                premiumHighlight(icon: "person.3.fill", label: "Team")
                premiumHighlight(icon: "doc.richtext", label: "Briefings")
                premiumHighlight(icon: "sparkles", label: "AI Coach")
            }
            .padding(.top, 4)
        }
    }

    private var trialBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "gift.fill")
                .font(.subheadline)
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text("7-Day Full Access Free Trial")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text("Experience every feature before you commit")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [PulseTheme.primaryTeal, PulseTheme.primaryTeal.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(.rect(cornerRadius: 14))
    }

    private func premiumHighlight(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
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

            Text("INCLUDED IN FREE")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)

            comparisonRow("Full 40-question assessment", free: true, business: true)
            comparisonRow("Overall Pulse Score", free: true, business: true)
            comparisonRow("Basic category scores", free: true, business: true)
            comparisonRow("One share card style", free: true, business: true)

            Divider().padding(.vertical, 6)

            Text("BUSINESS ONLY")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(PulseTheme.primaryTeal)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)

            comparisonRow("Detailed category analysis", free: false, business: true)
            comparisonRow("Industry benchmarking", free: false, business: true)
            comparisonRow("12-week personalized roadmap", free: false, business: true)
            comparisonRow("PDF diagnostic report", free: false, business: true)
            comparisonRow("Score history & trends", free: false, business: true)
            comparisonRow("All share card styles", free: false, business: true)
            comparisonRow("Reassessment insights", free: false, business: true)
            comparisonRow("Streak tracking & milestones", free: false, business: true)
            comparisonRow("Weekly check-in recaps", free: false, business: true)
            comparisonRow("Quarterly executive briefing", free: false, business: true)
            comparisonRow("Team assessments (up to 5)", free: false, business: true)

            Divider().padding(.vertical, 6)

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

                Text("Business")
                    .font(.caption2.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
                    .frame(width: 65)
            }
            .padding(.bottom, 4)

            aiLimitRow("AI Coach chat", freeLabel: "\u{2014}", businessLabel: "50/day")
            aiLimitRow("AI insights", freeLabel: "5/day", businessLabel: "25/day")
            aiLimitRow("Category Q&A", freeLabel: "2/day", businessLabel: "15/day")
        }
    }

    private func aiLimitRow(_ feature: String, freeLabel: String, businessLabel: String) -> some View {
        HStack {
            Text(feature)
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(freeLabel)
                .font(.caption2.bold())
                .foregroundStyle(freeLabel == "\u{2014}" ? Color(.tertiaryLabel) : .secondary)
                .frame(width: 50)

            Text(businessLabel)
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

            Text("Business")
                .font(.caption.bold())
                .foregroundStyle(PulseTheme.primaryTeal)
                .frame(width: 65)
        }
        .padding(.bottom, 8)
    }

    private func comparisonRow(_ feature: String, free: Bool, business: Bool) -> some View {
        HStack {
            Text(feature)
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: free ? "checkmark" : "xmark")
                .font(.caption2.bold())
                .foregroundStyle(free ? .green : Color(.tertiaryLabel))
                .frame(width: 50)

            Image(systemName: business ? "checkmark" : "xmark")
                .font(.caption2.bold())
                .foregroundStyle(business ? PulseTheme.primaryTeal : Color(.tertiaryLabel))
                .frame(width: 65)
        }
        .padding(.vertical, 5)
    }

    private var premiumServicesTeaser: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("Premium Advisory Services")
                    .font(.subheadline.bold())
            }

            Text("Need deeper support? M5CAIRO offers premium add-ons for Business subscribers:")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 8) {
                premiumServiceRow(icon: "person.2.fill", title: "1-on-1 Strategy Consultation", desc: "Custom AI integration planning")
                premiumServiceRow(icon: "doc.text.magnifyingglass", title: "Custom KPI Tracking", desc: "Correlate metrics with Pulse Score")
                premiumServiceRow(icon: "chart.bar.doc.horizontal", title: "Board-Ready Reports", desc: "Investor-grade presentation decks")
            }

            if let url = URL(string: "mailto:contact@m5cairo.com?subject=Premium%20Advisory%20Services") {
                Link(destination: url) {
                    Text("Contact for Pricing")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.orange.opacity(0.2), lineWidth: 1)
        )
    }

    private func premiumServiceRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.orange)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.bold())
                Text(desc)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
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
                                    Text("SAVE 33%")
                                        .font(.system(size: 9, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(PulseTheme.primaryTeal)
                                        .clipShape(Capsule())
                                }
                            }

                            if let intro = package.storeProduct.introductoryDiscount {
                                Text("\(intro.subscriptionPeriod.value)-\(unitLabel(intro.subscriptionPeriod.unit)) free trial included")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            } else {
                                Text(package.storeProduct.localizedDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(package.storeProduct.localizedPriceString)
                                .font(.subheadline.bold())
                                .foregroundStyle(isSelected ? PulseTheme.primaryTeal : .primary)
                            if isAnnual {
                                Text("per year")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("per month")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
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
            return "Start 7-Day Free Trial"
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
