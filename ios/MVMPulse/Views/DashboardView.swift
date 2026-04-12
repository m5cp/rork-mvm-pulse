import SwiftUI
import Charts

struct DashboardView: View {
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @Binding var selectedTab: AppTab
    @State private var showAssessment: Bool = false
    @State private var showDeepDive: Bool = false
    @State private var showResults: Bool = false
    @State private var pendingResult: AssessmentResult?
    @State private var showPaywall: Bool = false
    @State private var showMilestone: StreakMilestone?
    @State private var cardsAppeared: Bool = false
    @State private var showTaskCompletion: Bool = false
    @State private var showCheckIn: Bool = false
    @State private var showGoalSetting: Bool = false
    @State private var showAssessmentHistory: Bool = false
    @State private var selectedCategory: AssessmentCategory?
    @State private var taskCompletionHaptic: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = storage.userProfile.firstName.isEmpty ? "" : ", \(storage.userProfile.firstName)"
        switch hour {
        case 5..<12: return "Good morning\(name)"
        case 12..<17: return "Good afternoon\(name)"
        case 17..<22: return "Good evening\(name)"
        default: return "Good evening\(name)"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if storage.hasCompletedAssessment {
                        populatedDashboard
                    } else {
                        emptyDashboard
                    }
                }
                .navigationTitle(greeting)
                .fullScreenCover(isPresented: $showAssessment) {
                    NavigationStack {
                        AssessmentFlowContainer(storage: storage, store: store, ai: ai, selectedTab: $selectedTab, mode: .quick)
                    }
                }
                .fullScreenCover(isPresented: $showDeepDive) {
                    NavigationStack {
                        AssessmentFlowContainer(storage: storage, store: store, ai: ai, selectedTab: $selectedTab, mode: .deepDive)
                    }
                }
                .sheet(item: $showMilestone) { milestone in
                    MilestoneView(milestone: milestone)
                }
                .sheet(isPresented: $showGoalSetting) {
                    NavigationStack {
                        GoalSettingView(storage: storage)
                    }
                }
                .sheet(isPresented: $showAssessmentHistory) {
                    NavigationStack {
                        AssessmentHistoryView(storage: storage, store: store, ai: ai)
                    }
                }
                .sheet(item: $selectedCategory) { category in
                    NavigationStack {
                        CategoryDeepDiveView(category: category, storage: storage, store: store, ai: ai)
                    }
                }
                .sensoryFeedback(.success, trigger: taskCompletionHaptic)

                if showTaskCompletion {
                    TaskCompletionOverlay(isShowing: $showTaskCompletion)
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
        }
    }

    private var emptyDashboard: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 60)

                VStack(spacing: 24) {
                    ZStack {
                        ForEach(0..<8, id: \.self) { i in
                            let category = AssessmentCategory.allCases[i]
                            Circle()
                                .fill(PulseTheme.categoryColor(for: category).opacity(0.12))
                                .frame(width: 140, height: 140)
                                .offset(
                                    x: cos(Double(i) * .pi / 4) * 14,
                                    y: sin(Double(i) * .pi / 4) * 14
                                )
                                .blur(radius: 28)
                        }

                        Circle()
                            .stroke(PulseTheme.primaryTeal.opacity(0.2), lineWidth: 12)
                            .frame(width: 140, height: 140)

                        Circle()
                            .trim(from: 0, to: cardsAppeared ? 0.06 : 0.001)
                            .stroke(PulseTheme.primaryTeal.opacity(0.6), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))

                        Text("?")
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundStyle(PulseTheme.primaryTeal.opacity(cardsAppeared ? 0.5 : 0))
                    }
                    .opacity(cardsAppeared ? 1 : 0)
                    .scaleEffect(cardsAppeared ? 1 : 0.8)

                    VStack(spacing: 8) {
                        Text("Take your first assessment")
                            .font(.title2.bold())

                        Text("24 questions across 8 dimensions.\nAbout 2\u{2013}3 minutes to complete.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(cardsAppeared ? 1 : 0)
                    .offset(y: cardsAppeared ? 0 : 15)
                }
                .padding(.horizontal, 32)

                Button {
                    showAssessment = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.subheadline)
                        Text("Start Quick Pulse")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)
                .padding(.horizontal, 24)
                .opacity(cardsAppeared ? 1 : 0)
                .offset(y: cardsAppeared ? 0 : 20)

                Spacer(minLength: 40)
            }
            .onAppear {
                guard !cardsAppeared else { return }
                withAnimation(reduceMotion ? .none : .spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                    cardsAppeared = true
                }
            }
        }
    }

    private var populatedDashboard: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let result = storage.latestResult {
                    heroScoreCard(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 0, reduceMotion: reduceMotion)

                    if let goal = storage.goalData {
                        goalProgressCard(result: result, goal: goal)
                            .staggerIn(appeared: cardsAppeared, index: 1, reduceMotion: reduceMotion)
                    }

                    contextualMotivator(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 2, reduceMotion: reduceMotion)

                    if !storage.hasCheckedInToday && storage.hasCompletedAssessment {
                        DailyCheckInView(storage: storage, ai: ai) {
                            showCheckIn = false
                        }
                        .staggerIn(appeared: cardsAppeared, index: 3, reduceMotion: reduceMotion)
                    }

                    dailyTipCard(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 4, reduceMotion: reduceMotion)

                    if !result.isRefined {
                        refineScoreCard(result: result)
                            .staggerIn(appeared: cardsAppeared, index: 5, reduceMotion: reduceMotion)
                    }

                    categoryBars(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 6, reduceMotion: reduceMotion)

                    if storage.assessmentResults.count >= 2 {
                        scoreHistoryChart
                            .staggerIn(appeared: cardsAppeared, index: 7, reduceMotion: reduceMotion)
                    }

                    statCards(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 8, reduceMotion: reduceMotion)
                }

                if let task = storage.roadmap.todaysTask, store.isPremium {
                    todaysTaskCard(task: task)
                        .staggerIn(appeared: cardsAppeared, index: 9, reduceMotion: reduceMotion)
                }

                if store.isPremium {
                    streakCard
                        .staggerIn(appeared: cardsAppeared, index: 10, reduceMotion: reduceMotion)
                }

                if let comebackMessage = storage.streakData.comebackMessage {
                    comebackCard(message: comebackMessage)
                        .staggerIn(appeared: cardsAppeared, index: 11, reduceMotion: reduceMotion)
                }

                if store.isPremium, let result = storage.latestResult {
                    insightsSection(result: result)
                        .staggerIn(appeared: cardsAppeared, index: 12, reduceMotion: reduceMotion)
                }

                if !store.isPremium {
                    premiumPromptCard
                        .staggerIn(appeared: cardsAppeared, index: 12, reduceMotion: reduceMotion)
                }

                if !storage.dailyCheckIns.isEmpty {
                    moodTrendCard
                        .staggerIn(appeared: cardsAppeared, index: 13, reduceMotion: reduceMotion)
                }

                reassessmentPrompt
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .onAppear {
                guard !cardsAppeared else { return }
                withAnimation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8)) {
                    cardsAppeared = true
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showGoalSetting = true
                    } label: {
                        Label(storage.goalData == nil ? "Set Goal" : "Edit Goal", systemImage: "target")
                    }
                    Button {
                        showAssessmentHistory = true
                    } label: {
                        Label("Assessment History", systemImage: "clock.arrow.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                }
                .sensoryFeedback(.selection, trigger: showGoalSetting)
            }
        }
    }

    private func goalProgressCard(result: AssessmentResult, goal: GoalData) -> some View {
        let current = result.overallScore
        let target = goal.targetScore
        let progress = min(1.0, current / target)
        let pointsLeft = max(0, Int(target) - Int(current))
        let daysLeft = max(0, Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0)

        return Button {
            showGoalSetting = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 5)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(PulseTheme.primaryTeal, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "target")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.primaryTeal)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Goal: \(Int(target))")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    if pointsLeft > 0 {
                        Text("\(pointsLeft) points to go \u{00B7} \(daysLeft) days left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Goal reached!")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(PulseTheme.primaryTeal.opacity(0.06))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(PulseTheme.primaryTeal.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func dailyTipCard(result: AssessmentResult) -> some View {
        let tip = DailyTipsEngine.tipOfTheDay(for: result, streakData: storage.streakData)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: ai.aiDailyTip != nil ? "sparkles" : tip.icon)
                    .font(.subheadline)
                    .foregroundStyle(ai.aiDailyTip != nil ? PulseTheme.primaryTeal : (tip.category.map { PulseTheme.categoryColor(for: $0) } ?? .orange))

                Text(ai.aiDailyTip != nil ? "AI Coach" : tip.title)
                    .font(.subheadline.bold())

                Spacer()

                if ai.isLoadingTip {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Daily Tip")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Text(ai.aiDailyTip ?? tip.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if ai.aiDailyTip == nil, let actionLabel = tip.actionLabel {
                Button {
                    selectedTab = .roadmap
                } label: {
                    Text(actionLabel)
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
                .sensoryFeedback(.selection, trigger: selectedTab)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .onAppear {
            ai.loadDailyTip(result: result, profile: storage.userProfile, streakDays: storage.streakData.currentStreak)
        }
    }

    private var moodTrendCard: some View {
        let recentCheckIns = Array(storage.dailyCheckIns.suffix(7))
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundStyle(.pink)
                Text("Mood Trend")
                    .font(.subheadline.bold())
                Spacer()
                Text("Last \(recentCheckIns.count) days")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                ForEach(recentCheckIns) { checkIn in
                    VStack(spacing: 4) {
                        Text(checkIn.mood.emoji)
                            .font(.title3)
                        Text(checkIn.date, format: .dateTime.weekday(.abbreviated))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private func contextualMotivator(result: AssessmentResult) -> some View {
        let score = result.overallScore
        let level = result.level

        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: motivatorIcon(level: level, score: score))
                    .font(.subheadline)
                    .foregroundStyle(motivatorColor(level: level))

                Text(motivatorText(result: result))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(14)
        }
        .background(motivatorColor(level: level).opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func motivatorIcon(level: ScoreLevel, score: Double) -> String {
        switch level {
        case .critical: return "exclamationmark.triangle.fill"
        case .atRisk: return "arrow.up.right"
        case .developing: return "chart.line.uptrend.xyaxis"
        case .strong: return "star.fill"
        case .elite: return "crown.fill"
        }
    }

    private func motivatorColor(level: ScoreLevel) -> Color {
        PulseTheme.scoreColor(for: level)
    }

    private func motivatorText(result: AssessmentResult) -> String {
        let score = Int(result.overallScore)
        let level = result.level

        switch level {
        case .critical:
            return "Your score of \(score) has room for significant improvement. Focus on one category at a time."
        case .atRisk:
            let toNext = 35 - score
            return "You're \(max(1, toNext)) points from Developing. Small, consistent actions close this gap."
        case .developing:
            let toNext = 50 - score
            return "You're \(max(1, toNext)) points from Strong. Your roadmap targets the fastest path there."
        case .strong:
            let toNext = 65 - score
            return "Just \(max(1, toNext)) points from Elite. Refine your weakest area to cross the threshold."
        case .elite:
            return "Elite performance. Maintain your edge by optimizing your weakest dimension."
        }
    }

    private func heroScoreCard(result: AssessmentResult) -> some View {
        VStack(spacing: 16) {
            ScoreRingView(score: result.overallScore, size: 160, lineWidth: 14, animated: false)

            if !result.isRefined {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("Quick Pulse")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.orange.opacity(0.1))
                .clipShape(Capsule())
            }

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("Last assessed \(result.date, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private func refineScoreCard(result: AssessmentResult) -> some View {
        let unrefinedCount = result.unrefinedCategories.count
        let deepDiveQuestionCount = QuestionBank.deepDiveQuestions(for: result.unrefinedCategories).count

        return Button {
            showDeepDive = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.body.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Refine Your Score")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("\(deepDiveQuestionCount) more questions across \(unrefinedCount) categories")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("~\(max(1, deepDiveQuestionCount / 3))m")
                    .font(.caption.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PulseTheme.primaryTeal.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [PulseTheme.primaryTeal.opacity(0.04), PulseTheme.primaryTeal.opacity(0.08)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func categoryBars(result: AssessmentResult) -> some View {
        VStack(spacing: 10) {
            ForEach(result.categoryScores) { cs in
                let catColor = PulseTheme.categoryColor(for: cs.category)
                Button {
                    selectedCategory = cs.category
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: cs.category.icon)
                            .font(.caption2)
                            .foregroundStyle(catColor)
                            .frame(width: 16)

                        Text(cs.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .leading)
                            .lineLimit(1)

                        MiniProgressBar(
                            value: cs.normalizedScore,
                            color: catColor,
                            height: 8
                        )

                        Text("\(Int(cs.normalizedScore))%")
                            .font(.caption.bold())
                            .foregroundStyle(catColor)
                            .frame(width: 36, alignment: .trailing)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.quaternary)
                    }
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: selectedCategory)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var scoreHistoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Score History")
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    showAssessmentHistory = true
                } label: {
                    Text("View All")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
            }

            Chart(storage.assessmentResults, id: \.id) { result in
                LineMark(
                    x: .value("Date", result.date),
                    y: .value("Score", result.overallScore)
                )
                .foregroundStyle(PulseTheme.primaryTeal)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", result.date),
                    y: .value("Score", result.overallScore)
                )
                .foregroundStyle(PulseTheme.primaryTeal)
                .annotation(position: .top, spacing: 4) {
                    Text("\(Int(result.overallScore))")
                        .font(.caption2.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100])
            }
            .frame(height: 160)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func statCards(result: AssessmentResult) -> some View {
        HStack(spacing: 12) {
            let strongCat = result.strongestCategory?.category
            let weakCat = result.weakestCategory?.category
            statCard(
                title: "Strongest",
                value: strongCat?.rawValue ?? "\u{2014}",
                icon: "arrow.up.circle.fill",
                color: strongCat.map { PulseTheme.categoryColor(for: $0) } ?? .green
            )
            statCard(
                title: "Weakest",
                value: weakCat?.rawValue ?? "\u{2014}",
                icon: "arrow.down.circle.fill",
                color: weakCat.map { PulseTheme.categoryColor(for: $0) } ?? .red
            )
            statCard(
                title: "Trend",
                value: trendDirection,
                icon: trendIcon,
                color: trendColor
            )
        }
    }

    private var trendDirection: String {
        guard storage.assessmentResults.count >= 2 else { return "\u{2014}" }
        let last = storage.assessmentResults.last!.overallScore
        let prev = storage.assessmentResults[storage.assessmentResults.count - 2].overallScore
        if last > prev { return "Up" }
        if last < prev { return "Down" }
        return "Flat"
    }

    private var trendIcon: String {
        guard storage.assessmentResults.count >= 2 else { return "minus.circle.fill" }
        let last = storage.assessmentResults.last!.overallScore
        let prev = storage.assessmentResults[storage.assessmentResults.count - 2].overallScore
        if last > prev { return "arrow.up.right.circle.fill" }
        if last < prev { return "arrow.down.right.circle.fill" }
        return "minus.circle.fill"
    }

    private var trendColor: Color {
        guard storage.assessmentResults.count >= 2 else { return .secondary }
        let last = storage.assessmentResults.last!.overallScore
        let prev = storage.assessmentResults[storage.assessmentResults.count - 2].overallScore
        if last > prev { return .green }
        if last < prev { return .red }
        return .secondary
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.caption2.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func todaysTaskCard(task: RoadmapTask) -> some View {
        let catColor = PulseTheme.categoryColor(for: task.category)
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today\u{2019}s Task", systemImage: "checkmark.circle")
                    .font(.subheadline.bold())
                    .foregroundStyle(catColor)
                Spacer()
                Text(task.timeEstimate)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(catColor.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(task.title)
                .font(.headline)

            Text(task.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Button {
                completeTask(task)
            } label: {
                Text("Mark Complete")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(catColor)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(catColor.opacity(0.15), lineWidth: 1)
        )
    }

    private var streakCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(storage.streakData.currentStreak)-day streak")
                    .font(.subheadline.bold())
                Text("Longest: \(storage.streakData.longestStreak) days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(storage.streakData.totalDaysActive)")
                .font(.title2.bold())
                .foregroundStyle(PulseTheme.primaryTeal)

            Text("total\ndays")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func comebackCard(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.wave.fill")
                .font(.title3)
                .foregroundStyle(PulseTheme.primaryTeal)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func insightsSection(result: AssessmentResult) -> some View {
        let insights = InsightsEngine.generateInsights(
            result: result,
            roadmap: storage.roadmap,
            streakData: storage.streakData
        )
        let completedTasks = storage.roadmap.weeks.flatMap(\.tasks).filter(\.isCompleted).count
        let totalTasks = storage.roadmap.weeks.flatMap(\.tasks).count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: ai.aiWeeklyInsights != nil ? "sparkles" : "lightbulb.fill")
                    .foregroundStyle(ai.aiWeeklyInsights != nil ? PulseTheme.primaryTeal : .orange)
                Text("Weekly Insights")
                    .font(.subheadline.bold())
                Spacer()
                if ai.isLoadingInsights {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            if let aiInsights = ai.aiWeeklyInsights {
                ForEach(Array(aiInsights.prefix(3).enumerated()), id: \.offset) { index, insight in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: ["brain.head.profile", "target", "chart.line.uptrend.xyaxis"][index % 3])
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.primaryTeal)
                            .frame(width: 24, height: 24)

                        Text(insight)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            } else {
                ForEach(insights.prefix(3)) { insight in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.subheadline)
                            .foregroundStyle(insight.category.map { PulseTheme.categoryColor(for: $0) } ?? PulseTheme.primaryTeal)
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(insight.title)
                                .font(.caption.bold())
                            Text(insight.body)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .onAppear {
            ai.loadWeeklyInsights(result: result, profile: storage.userProfile, completedTasks: completedTasks, totalTasks: totalTasks)
        }
    }

    private var premiumPromptCard: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Unlock your full diagnostic")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("Get detailed analysis, roadmap, and PDF reports")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView(store: store)
            }
        }
    }

    private var reassessmentPrompt: some View {
        Group {
            if let lastResult = storage.latestResult {
                let daysSince = Calendar.current.dateComponents([.day], from: lastResult.date, to: Date()).day ?? 0
                if daysSince >= 30 {
                    Button {
                        showAssessment = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title3)
                                .foregroundStyle(PulseTheme.primaryTeal)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Time for a reassessment")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.primary)
                                Text("It\u{2019}s been \(daysSince) days since your last assessment")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(PulseTheme.primaryTeal.opacity(0.06))
                        .clipShape(.rect(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func completeTask(_ task: RoadmapTask) {
        guard let weekIdx = storage.roadmap.weeks.firstIndex(where: { $0.tasks.contains(where: { $0.id == task.id }) }),
              let taskIdx = storage.roadmap.weeks[weekIdx].tasks.firstIndex(where: { $0.id == task.id }) else { return }

        storage.roadmap.weeks[weekIdx].tasks[taskIdx].isCompleted = true
        storage.roadmap.weeks[weekIdx].tasks[taskIdx].completedDate = Date()
        storage.recordActivity()

        taskCompletionHaptic += 1
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showTaskCompletion = true
        }

        if storage.roadmap.weeks[weekIdx].isComplete {
            let nextIdx = weekIdx + 1
            if nextIdx < storage.roadmap.weeks.count {
                storage.roadmap.weeks[nextIdx].isUnlocked = true
            }
        }

        let newMilestones = storage.streakData.milestones.filter { m in
            !storage.streakData.milestones.dropLast().contains(where: { $0.days == m.days })
        }
        if let latest = newMilestones.last {
            showMilestone = latest
        }
    }
}

struct AssessmentFlowContainer: View {
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @Binding var selectedTab: AppTab
    let mode: AssessmentMode
    @State private var phase: AssessmentFlowPhase = .questions
    @State private var result: AssessmentResult?
    @Environment(\.dismiss) private var dismiss

    enum AssessmentFlowPhase {
        case questions, emailGate, calculating, results
    }

    private var questionsForMode: [AssessmentQuestion] {
        switch mode {
        case .quick:
            return QuestionBank.coreQuestions
        case .full:
            return QuestionBank.allQuestions
        case .deepDive:
            guard let latest = storage.latestResult else { return QuestionBank.deepDiveQuestions }
            let unrefinedCategories = latest.unrefinedCategories
            return QuestionBank.deepDiveQuestions(for: unrefinedCategories)
        }
    }

    private var existingResponses: [AssessmentResponse] {
        if mode == .deepDive, let latest = storage.latestResult {
            return latest.responses
        }
        return []
    }

    var body: some View {
        switch phase {
        case .questions:
            AssessmentView(
                questions: questionsForMode,
                mode: mode,
                existingResponses: [],
                onComplete: { newResponses in
                    if mode == .deepDive, let existing = storage.latestResult {
                        result = ScoringEngine.refineAssessment(existing: existing, newResponses: newResponses)
                    } else {
                        result = ScoringEngine.processAssessment(responses: newResponses, mode: mode)
                    }

                    if storage.hasCompletedAssessment {
                        if let result {
                            if mode == .deepDive {
                                if let idx = storage.assessmentResults.indices.last {
                                    storage.assessmentResults[idx] = result
                                }
                            } else {
                                storage.assessmentResults.append(result)
                            }
                            let roadmap = RoadmapGenerator.generate(from: result)
                            storage.roadmap = roadmap
                        }
                        phase = .calculating
                    } else {
                        phase = .emailGate
                    }
                }
            )
        case .emailGate:
            EmailGateView(storage: storage) {
                if let result {
                    storage.assessmentResults.append(result)
                    let roadmap = RoadmapGenerator.generate(from: result)
                    storage.roadmap = roadmap
                }
                phase = .calculating
            }
        case .calculating:
            ScoreCalculatingView {
                phase = .results
            }
        case .results:
            if let result {
                ResultsView(result: result, storage: storage, store: store, ai: ai)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { dismiss() }
                        }
                    }
            }
        }
    }
}
