import SwiftUI
import Charts

struct CategoryDeepDiveView: View {
    let category: AssessmentCategory
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var askAIQuestion: String = ""
    @State private var askAIAnswer: String?
    @State private var isAskingAI: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var catColor: Color {
        PulseTheme.categoryColor(for: category)
    }

    private var currentScore: Double {
        storage.latestResult?.categoryScores.first(where: { $0.category == category })?.normalizedScore ?? 0
    }

    private var scoreHistory: [(date: Date, score: Double)] {
        storage.assessmentResults.compactMap { result in
            guard let cs = result.categoryScores.first(where: { $0.category == category }) else { return nil }
            return (date: result.date, score: cs.normalizedScore)
        }
    }

    private var relatedTasks: [RoadmapTask] {
        storage.roadmap.weeks.flatMap(\.tasks).filter { $0.category == category }
    }

    private var analysis: AnalysisEngine.CategoryAnalysis {
        AnalysisEngine.categoryAnalysis(category: category, score: currentScore)
    }

    private var percentile: Int {
        BenchmarkEngine.categoryBenchmark(category: category, score: currentScore)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                    .staggerIn(appeared: appeared, index: 0, reduceMotion: reduceMotion)

                if scoreHistory.count >= 2 {
                    historyChart
                        .staggerIn(appeared: appeared, index: 1, reduceMotion: reduceMotion)
                }

                benchmarkCard
                    .staggerIn(appeared: appeared, index: 2, reduceMotion: reduceMotion)

                if store.isPremium {
                    analysisCard
                        .staggerIn(appeared: appeared, index: 3, reduceMotion: reduceMotion)
                }

                if !relatedTasks.isEmpty && store.isPremium {
                    tasksCard
                        .staggerIn(appeared: appeared, index: 4, reduceMotion: reduceMotion)
                }

                tipCard
                    .staggerIn(appeared: appeared, index: 5, reduceMotion: reduceMotion)

                if ai.isAvailable && store.isPremium {
                    askAICard
                        .staggerIn(appeared: appeared, index: 6, reduceMotion: reduceMotion)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear {
            guard !appeared else { return }
            withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(catColor.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(catColor)
            }

            VStack(spacing: 6) {
                Text("\(Int(currentScore))%")
                    .font(.system(size: 44, weight: .heavy))
                    .foregroundStyle(catColor)

                Text(ScoreLevel.from(score: currentScore).rawValue)
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
            }

            MiniProgressBar(value: currentScore, color: catColor, height: 10)
                .padding(.horizontal, 20)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var historyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score History")
                .font(.subheadline.bold())

            Chart(scoreHistory, id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(catColor)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(catColor)
                .annotation(position: .top, spacing: 4) {
                    Text("\(Int(entry.score))%")
                        .font(.caption2.bold())
                        .foregroundStyle(catColor)
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100])
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var benchmarkCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(catColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(catColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Benchmark")
                    .font(.subheadline.bold())
                Text("Higher than \(percentile)% of users in this category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(percentile)th")
                .font(.title3.bold())
                .foregroundStyle(catColor)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis")
                .font(.subheadline.bold())

            VStack(alignment: .leading, spacing: 12) {
                analysisRow(title: "What This Means", text: analysis.whatThisMeans)

                if !analysis.opportunities.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Opportunities")
                            .font(.caption.bold())
                            .foregroundStyle(catColor)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        ForEach(analysis.opportunities, id: \.self) { opp in
                            HStack(alignment: .top, spacing: 6) {
                                Text("\u{2022}")
                                    .foregroundStyle(.secondary)
                                Text(opp)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                analysisRow(title: "Next Step", text: analysis.recommendedNextStep)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func analysisRow(title: String, text: String) -> some View {
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

    private var tasksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Tasks")
                .font(.subheadline.bold())

            let tasks = relatedTasks.prefix(5)
            ForEach(Array(tasks)) { task in
                HStack(spacing: 10) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(task.isCompleted ? catColor : Color(.separator))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.subheadline)
                            .strikethrough(task.isCompleted)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                        Text(task.timeEstimate)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()
                }
            }

            let completedCount = relatedTasks.filter(\.isCompleted).count
            let totalCount = relatedTasks.count
            if totalCount > 0 {
                HStack(spacing: 6) {
                    MiniProgressBar(value: Double(completedCount) / Double(totalCount) * 100, color: catColor, height: 6)
                    Text("\(completedCount)/\(totalCount)")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var tipCard: some View {
        let tips = categoryTips
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let tip = tips[dayOfYear % tips.count]

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Daily Tip")
                    .font(.subheadline.bold())
            }

            Text(tip)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(.orange.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var askAICard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Ask AI")
                    .font(.subheadline.bold())
            }

            Text("Ask anything about your \(category.rawValue) score")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                TextField("e.g. How do I improve this?", text: $askAIQuestion)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 10))

                Button {
                    askAI()
                } label: {
                    if isAskingAI {
                        ProgressView()
                            .controlSize(.small)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                askAIQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color(.tertiaryLabel)
                                    : PulseTheme.primaryTeal
                            )
                    }
                }
                .disabled(askAIQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAskingAI)
            }

            if let answer = askAIAnswer {
                Text(answer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PulseTheme.primaryTeal.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 10))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    quickPromptChip("How do I improve this?")
                    quickPromptChip("What's a quick win?")
                    quickPromptChip("Why does this matter?")
                }
            }
            .contentMargins(.horizontal, 0)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func quickPromptChip(_ text: String) -> some View {
        Button {
            askAIQuestion = text
            askAI()
        } label: {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isAskingAI)
    }

    private var qaRemaining: Int {
        ai.usage.remaining(.categoryQA, tier: store.isPremium ? .premium : .free)
    }

    private func askAI() {
        let question = askAIQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !isAskingAI else { return }
        let tier: AIUsageTier = store.isPremium ? .premium : .free
        guard ai.usage.canPerform(.categoryQA, tier: tier) else {
            askAIAnswer = "You\u{2019}ve reached your daily Q&A limit. Resets at midnight."
            return
        }
        isAskingAI = true
        askAIAnswer = nil
        Task {
            let answer = await ai.router.generateCategoryQA(
                category: category,
                score: currentScore,
                question: question,
                profile: storage.userProfile
            )
            if answer != nil { ai.usage.recordUsage(.categoryQA) }
            askAIAnswer = answer ?? "I couldn't generate an answer right now. Please try again."
            isAskingAI = false
        }
    }

    private var categoryTips: [String] {
        switch category {
        case .financialHealth:
            return ["Review your cash flow statement weekly, not monthly.", "The best time to negotiate rates is before you need to.", "Track every expense for one week — patterns will surprise you."]
        case .operationsProductivity:
            return ["Batch similar tasks together to reduce context-switching.", "If you do it more than twice, document the process.", "Your energy peaks matter more than your time blocks."]
        case .leadershipStrategy:
            return ["Write your top 3 priorities before opening email.", "Reversible decisions should take minutes, not days.", "Review your quarterly goals every Monday morning."]
        case .teamCulture:
            return ["Specific praise builds more trust than general encouragement.", "Address small tensions before they become big conflicts.", "Ask 'What do you think?' before sharing your opinion."]
        case .technologyAI:
            return ["Automate one repetitive task this week.", "The best tool is the one you actually use consistently.", "Security hygiene: update passwords on your top 3 accounts."]
        case .customerMarket:
            return ["Talk to one customer this week about their biggest pain point.", "Study what your best competitor does differently.", "Your value proposition should fit in one sentence."]
        case .personalWellness:
            return ["A 10-minute walk improves focus for 2 hours.", "Set a hard stop time for work and honor it.", "Sleep consistency matters more than sleep duration."]
        case .growthLearning:
            return ["15 minutes of intentional learning daily compounds fast.", "Teaching others deepens your own understanding.", "Comfort zone expansion: do one slightly uncomfortable thing today."]
        }
    }
}
