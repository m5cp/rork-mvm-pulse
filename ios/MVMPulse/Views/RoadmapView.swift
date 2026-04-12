import SwiftUI

struct RoadmapView: View {
    let storage: StorageService
    let store: StoreViewModel
    var ai: AIViewModel = AIViewModel()
    @State private var showPaywall: Bool = false
    @State private var celebratingWeek: Int?
    @State private var showCelebration: Bool = false
    @State private var showTaskCompletion: Bool = false
    @State private var taskCompletionHaptic: Int = 0
    @State private var weeklyRecapText: String?
    @State private var isLoadingRecap: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    if storage.roadmap.weeks.isEmpty || !store.isPremium {
                        lockedState
                    } else {
                        roadmapContent
                    }
                }
                .navigationTitle("Roadmap")
                .sheet(isPresented: $showPaywall) {
                    NavigationStack {
                        PaywallView(store: store)
                    }
                }
                .fullScreenCover(isPresented: $showCelebration) {
                    if let week = celebratingWeek {
                        WeekCelebrationView(weekNumber: week) {
                            showCelebration = false
                            celebratingWeek = nil
                        }
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

    private var lockedState: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 24)

                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(PulseTheme.primaryTeal.opacity(0.4))

                VStack(spacing: 8) {
                    Text("Your 12-Week Roadmap")
                        .font(.title2.bold())

                    if !storage.hasCompletedAssessment {
                        Text("Complete your first assessment to generate a personalized roadmap.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Upgrade to Business to unlock your personalized 12-week action plan.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if storage.hasCompletedAssessment && !store.isPremium {
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Unlock Roadmap")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(PulseTheme.primaryTeal)
                }

                if storage.hasCompletedAssessment && !store.isPremium {
                    roadmapTeaser
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 32)
        }
    }

    private var roadmapTeaser: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.caption)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Preview of your roadmap")
                    .font(.caption.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in
                    teaserTaskRow(index: i)
                }
            }
            .blur(radius: 3)
            .allowsHitTesting(false)

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("Unlock with Premium to see all 12 weeks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PulseTheme.primaryTeal.opacity(0.1), lineWidth: 1)
        )
    }

    private func teaserTaskRow(index: Int) -> some View {
        let titles = ["Audit your current baseline", "Identify top 3 improvement areas", "Set measurable weekly targets"]
        let times = ["10 min", "15 min", "5 min"]
        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: "circle")
                .font(.title3)
                .foregroundStyle(Color(.separator))

            VStack(alignment: .leading, spacing: 4) {
                Text(titles[index])
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 8) {
                    Label(times[index], systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var roadmapContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                overallProgressCard

                if let recap = weeklyRecapText {
                    weeklyRecapCard(recap: recap)
                } else if isLoadingRecap {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text("Generating weekly recap...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(PulseTheme.primaryTeal.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 14))
                }

                if let currentWeek = storage.roadmap.currentWeek {
                    currentWeekHeader(week: currentWeek)
                }

                ForEach(Array(storage.roadmap.weeks.enumerated()), id: \.element.id) { index, week in
                    weekCard(week: week, index: index)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear { loadWeeklyRecap() }
    }

    private func weeklyRecapCard(recap: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Week \(storage.roadmap.currentWeek?.weekNumber ?? 1) Recap")
                    .font(.subheadline.bold())
                Spacer()
                Text("AI")
                    .font(.caption2.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(PulseTheme.primaryTeal.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(recap)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PulseTheme.primaryTeal.opacity(0.12), lineWidth: 1)
        )
    }

    private func loadWeeklyRecap() {
        guard !isLoadingRecap, weeklyRecapText == nil, store.isPremium else { return }
        guard let result = storage.latestResult, let week = storage.roadmap.currentWeek else { return }
        let completedThisWeek = week.tasks.filter(\.isCompleted).count
        let totalThisWeek = week.tasks.count
        guard completedThisWeek > 0 else { return }
        isLoadingRecap = true
        Task {
            let recap = await ai.groq.generateWeeklyRecap(
                weekNumber: week.weekNumber,
                completedTasks: completedThisWeek,
                totalTasks: totalThisWeek,
                result: result,
                profile: storage.userProfile,
                streakDays: storage.streakData.currentStreak
            )
            weeklyRecapText = recap
            isLoadingRecap = false
        }
    }

    private var overallProgressCard: some View {
        let progress = storage.roadmap.overallProgress
        let completedTasks = storage.roadmap.weeks.flatMap(\.tasks).filter(\.isCompleted).count
        let totalTasks = storage.roadmap.weeks.flatMap(\.tasks).count

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 5)
                    .frame(width: 44, height: 44)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(PulseTheme.primaryTeal, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.caption2.bold())
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Overall Progress")
                    .font(.subheadline.bold())
                Text("\(completedTasks) of \(totalTasks) tasks completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func currentWeekHeader(week: RoadmapWeek) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WEEK \(week.weekNumber)")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                        .tracking(1.5)

                    Text(week.theme)
                        .font(.title3.bold())

                    Text(week.phase)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: week.progress)
                        .stroke(PulseTheme.primaryTeal, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(week.progress * 100))%")
                        .font(.caption2.bold())
                }
                .frame(width: 52, height: 52)
            }

            if !week.insightText.isEmpty {
                Text(week.insightText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func weekCard(week: RoadmapWeek, index: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Week \(week.weekNumber)")
                    .font(.subheadline.bold())

                Text("\u{00B7} \(week.phase)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if week.isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if !week.isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.tertiary)
                        .font(.caption)
                }
            }

            if week.isUnlocked {
                ForEach(Array(week.tasks.enumerated()), id: \.element.id) { taskIndex, task in
                    taskRow(task: task, weekIndex: index, taskIndex: taskIndex)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
        .opacity(week.isUnlocked ? 1 : 0.6)
    }

    private func taskRow(task: RoadmapTask, weekIndex: Int, taskIndex: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                toggleTask(weekIndex: weekIndex, taskIndex: taskIndex)
            } label: {
                let taskCatColor = PulseTheme.categoryColor(for: task.category)
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? taskCatColor : Color(.separator))
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(task.isCompleted ? "Completed: \(task.title)" : "Incomplete: \(task.title)")

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(task.isCompleted ? .regular : .medium)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)

                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(task.timeEstimate, systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(task.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(PulseTheme.categoryColor(for: task.category))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(PulseTheme.categoryColor(for: task.category).opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func toggleTask(weekIndex: Int, taskIndex: Int) {
        guard weekIndex < storage.roadmap.weeks.count,
              taskIndex < storage.roadmap.weeks[weekIndex].tasks.count else { return }

        let wasComplete = storage.roadmap.weeks[weekIndex].isComplete
        let wasTaskCompleted = storage.roadmap.weeks[weekIndex].tasks[taskIndex].isCompleted

        storage.roadmap.weeks[weekIndex].tasks[taskIndex].isCompleted.toggle()
        if storage.roadmap.weeks[weekIndex].tasks[taskIndex].isCompleted {
            storage.roadmap.weeks[weekIndex].tasks[taskIndex].completedDate = Date()
            storage.recordActivity()

            if !wasTaskCompleted {
                taskCompletionHaptic += 1
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showTaskCompletion = true
                }
            }
        }

        let isNowComplete = storage.roadmap.weeks[weekIndex].isComplete
        if !wasComplete && isNowComplete {
            let nextIdx = weekIndex + 1
            if nextIdx < storage.roadmap.weeks.count {
                storage.roadmap.weeks[nextIdx].isUnlocked = true
            }
            Task {
                try? await Task.sleep(for: .seconds(2.0))
                celebratingWeek = storage.roadmap.weeks[weekIndex].weekNumber
                showCelebration = true
            }
        }
    }
}
