import SwiftUI

struct ResultsView: View {
    let result: AssessmentResult
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @State private var showShareComposer: Bool = false
    @State private var showPDFPreview: Bool = false
    @State private var expandedCategory: AssessmentCategory?
    @State private var appeared: Bool = false
    @State private var heroRevealed: Bool = false
    @State private var highlightRevealed: Bool = false
    @State private var cardsRevealed: Bool = false
    @State private var hapticTrigger: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection
                    .opacity(heroRevealed ? 1 : 0)
                    .scaleEffect(heroRevealed ? 1 : 0.9)

                benchmarkCard
                    .opacity(highlightRevealed ? 1 : 0)
                    .offset(y: highlightRevealed ? 0 : 20)

                narrativeHighlight
                    .opacity(highlightRevealed ? 1 : 0)
                    .offset(y: highlightRevealed ? 0 : 20)

                categoryCards
                    .opacity(cardsRevealed ? 1 : 0)
                    .offset(y: cardsRevealed ? 0 : 30)

                actionButtons
                    .opacity(cardsRevealed ? 1 : 0)
                    .offset(y: cardsRevealed ? 0 : 20)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .sheet(isPresented: $showShareComposer) {
            NavigationStack {
                ShareCardComposerView(result: result, storage: storage)
            }
        }
        .sheet(isPresented: $showPDFPreview) {
            NavigationStack {
                PDFPreviewView(result: result, storage: storage)
            }
        }
        .onAppear {
            guard !appeared else { return }
            appeared = true
            if reduceMotion {
                heroRevealed = true
                highlightRevealed = true
                cardsRevealed = true
                return
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                heroRevealed = true
            }
            hapticTrigger += 1
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
                highlightRevealed = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.6)) {
                cardsRevealed = true
            }
        }
    }

    private var benchmark: BenchmarkResult {
        BenchmarkEngine.benchmark(
            score: result.overallScore,
            role: storage.userProfile.role,
            industry: storage.userProfile.industry
        )
    }

    private var heroSection: some View {
        VStack(spacing: 20) {
            ScoreRingView(
                score: result.overallScore,
                size: 200,
                lineWidth: 16,
                animated: appeared,
                showGlow: true
            )
            .padding(.top, 8)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text(result.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var benchmarkCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chart.bar.fill")
                        .font(.body)
                        .foregroundStyle(PulseTheme.primaryTeal)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(benchmark.label)
                        .font(.subheadline.bold())
                    Text(benchmark.context)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(benchmark.percentile)")
                        .font(.title2.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                    Text("percentile")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(16)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PulseTheme.primaryTeal.opacity(0.12), lineWidth: 1)
        )
    }

    private var narrativeHighlight: some View {
        VStack(spacing: 16) {
            if let strongest = result.strongestCategory, let weakest = result.weakestCategory {
                HStack(spacing: 12) {
                    highlightPill(
                        label: "Strongest",
                        category: strongest.category,
                        score: Int(strongest.normalizedScore),
                        icon: "arrow.up.circle.fill",
                        isPositive: true
                    )
                    highlightPill(
                        label: "Needs Work",
                        category: weakest.category,
                        score: Int(weakest.normalizedScore),
                        icon: "arrow.down.circle.fill",
                        isPositive: false
                    )
                }
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Executive Summary")
                        .font(.headline)
                    Spacer()
                    if ai.isAvailable {
                        if ai.isLoadingSummary {
                            ProgressView()
                                .controlSize(.small)
                        } else if ai.aiSummary != nil {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(PulseTheme.primaryTeal)
                        }
                    }
                }

                if let aiText = ai.aiSummary {
                    Text(aiText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(AnalysisEngine.executiveSummary(result: result, profile: storage.userProfile))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
            .onAppear {
                ai.loadExecutiveSummary(result: result, profile: storage.userProfile)
            }
        }
    }

    private func highlightPill(label: String, category: AssessmentCategory, score: Int, icon: String, isPositive: Bool) -> some View {
        let catColor = PulseTheme.categoryColor(for: category)
        return VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(isPositive ? .green : .orange)
                Text(label.uppercased())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }

            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(catColor)

            Text(category.rawValue)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text("\(score)%")
                .font(.title3.bold())
                .foregroundStyle(catColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(catColor.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(catColor.opacity(0.12), lineWidth: 1)
        )
    }

    private var categoryCards: some View {
        VStack(spacing: 12) {
            Text("Category Breakdown")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(result.categoryScores.enumerated()), id: \.element.id) { index, cs in
                CategoryResultCard(
                    categoryScore: cs,
                    isExpanded: expandedCategory == cs.category,
                    isPremium: store.isPremium
                ) {
                    withAnimation(.snappy) {
                        expandedCategory = expandedCategory == cs.category ? nil : cs.category
                    }
                }
                .staggerIn(appeared: cardsRevealed, index: index, reduceMotion: reduceMotion)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if store.isPremium {
                Button {
                    showPDFPreview = true
                } label: {
                    Label("Download PDF Report", systemImage: "doc.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)
            }

            Button {
                showShareComposer = true
            } label: {
                Label("Share Your Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(PulseTheme.primaryTeal)
        }
        .padding(.top, 8)
    }
}

struct CategoryResultCard: View {
    let categoryScore: CategoryScore
    let isExpanded: Bool
    let isPremium: Bool
    let onTap: () -> Void

    private var analysis: AnalysisEngine.CategoryAnalysis {
        AnalysisEngine.categoryAnalysis(category: categoryScore.category, score: categoryScore.normalizedScore)
    }

    private var catColor: Color {
        PulseTheme.categoryColor(for: categoryScore.category)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: categoryScore.category.icon)
                        .font(.body)
                        .foregroundStyle(catColor)
                        .frame(width: 32, height: 32)
                        .background(catColor.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(categoryScore.category.rawValue)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)

                        MiniProgressBar(value: categoryScore.normalizedScore, color: catColor, height: 6)
                    }

                    Text("\(Int(categoryScore.normalizedScore))")
                        .font(.title3.bold())
                        .foregroundStyle(catColor)
                        .frame(width: 40, alignment: .trailing)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .padding(16)

            if isExpanded {
                if isPremium {
                    expandedContent
                } else {
                    premiumLock
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            analysisSection(title: "What This Means", text: analysis.whatThisMeans)

            analysisSection(title: "Pain Points", bullets: analysis.painPoints)

            analysisSection(title: "Opportunities", bullets: analysis.opportunities)

            analysisSection(title: "Potential Impact", text: analysis.potentialImpact)

            analysisSection(title: "Recommended Next Step", text: analysis.recommendedNextStep)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var premiumLock: some View {
        VStack(spacing: 8) {
            Divider()
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(catColor)
                Text("Upgrade to Premium for detailed analysis")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func analysisSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(catColor)
                .textCase(.uppercase)
                .tracking(0.5)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func analysisSection(title: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(catColor)
                .textCase(.uppercase)
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 6) {
                        Text("\u{2022}")
                            .foregroundStyle(.secondary)
                        Text(bullet)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
