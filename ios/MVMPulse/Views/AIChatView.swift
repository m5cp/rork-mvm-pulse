import SwiftUI

struct AIChatView: View {
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showPaywall: Bool = false
    @FocusState private var isInputFocused: Bool

    private let router = AIServiceRouter()

    private var chatRemaining: Int {
        ai.usage.remaining(.chatMessage, tier: .premium)
    }

    private var chatLimit: Int {
        AIUsageLimits.premium.chatMessagesPerDay
    }

    private var suggestedPrompts: [String] {
        var prompts = [
            "What should I focus on this week?",
            "How do I improve my weakest area?"
        ]
        if let result = storage.latestResult {
            if let weakest = result.weakestCategory {
                prompts.append("Give me a plan for \(weakest.category.rawValue)")
            }
            if result.overallScore < 35 {
                prompts.append("What's the fastest way to raise my score?")
            }
            prompts.append("How do I compare to my industry?")
            prompts.append("Build me a 90-day AI integration plan")
        }
        if storage.assessmentResults.count >= 2 {
            prompts.append("How has my progress been?")
        }
        return prompts
    }

    var body: some View {
        NavigationStack {
            Group {
                if !store.isPremium {
                    lockedState
                } else if !ai.isAvailable {
                    unavailableState
                } else {
                    chatContent
                }
            }
            .navigationTitle("AI Coach")
            .sheet(isPresented: $showPaywall) {
                NavigationStack {
                    PaywallView(store: store)
                }
            }
        }
    }

    private var lockedState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(PulseTheme.primaryTeal.opacity(0.08))
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 44))
                    .foregroundStyle(PulseTheme.primaryTeal)
            }

            VStack(spacing: 8) {
                Text("AI Business Coach")
                    .font(.title2.bold())
                Text("Get personalized advice based on your\nassessment results, roadmap, and goals.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showPaywall = true
            } label: {
                Text("Unlock with Business")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(PulseTheme.primaryTeal)
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    private var unavailableState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "wifi.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("AI Coach Unavailable")
                .font(.title3.bold())
            Text("The AI service is temporarily unavailable.\nPlease try again later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var chatContent: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if messages.isEmpty {
                            welcomeCard
                                .padding(.top, 20)

                            suggestionChips
                                .padding(.top, 8)
                        }

                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Thinking...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .id("loading")
                        }

                        if chatRemaining == 0 && !isLoading {
                            usageLimitBanner
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        } else if isLoading {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    if newValue {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            usageIndicator

            inputBar
        }
    }

    private var usageIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkle")
                .font(.caption2)
                .foregroundStyle(chatRemaining > 10 ? PulseTheme.primaryTeal : (chatRemaining > 0 ? .orange : .red))
            Text("\(chatRemaining)/\(chatLimit) messages remaining today")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 3) {
                Image(systemName: ai.router.appleAI.isAvailable ? "apple.logo" : "cloud")
                    .font(.system(size: 8))
                Text(ai.activeProviderName)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var usageLimitBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.title3)
                .foregroundStyle(.orange)
            Text("Daily Limit Reached")
                .font(.subheadline.bold())
            Text("You\u{2019}ve used all \(chatLimit) AI Coach messages for today. Your limit resets at midnight.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.orange.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var welcomeCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Your AI Coach")
                    .font(.headline)
            }

            if let result = storage.latestResult {
                Text("I have full context on your Pulse Score of \(Int(result.overallScore)), your profile as a \(storage.userProfile.role.rawValue) in \(storage.userProfile.industry.rawValue), and your roadmap progress. Ask me anything.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Complete your first assessment and I'll be able to give you personalized coaching based on your results.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestedPrompts, id: \.self) { prompt in
                    Button {
                        sendMessage(prompt)
                    } label: {
                        Text(prompt)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(chatRemaining == 0)
                }
            }
        }
        .contentMargins(.horizontal, 4)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField(chatRemaining > 0 ? "Ask your coach..." : "Daily limit reached", text: $inputText, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 20))
                .focused($isInputFocused)
                .disabled(chatRemaining == 0)

            Button {
                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                sendMessage(text)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatRemaining == 0
                            ? Color(.tertiaryLabel)
                            : PulseTheme.primaryTeal
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading || chatRemaining == 0)
            .sensoryFeedback(.impact(weight: .light), trigger: messages.count)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func sendMessage(_ text: String) {
        guard ai.usage.canPerform(.chatMessage, tier: .premium) else { return }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        inputText = ""
        isInputFocused = false
        isLoading = true

        Task {
            let systemPrompt = buildSystemPrompt()
            let groqMessages = messages.map { GroqChatMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }

            let response = await router.chatConversation(messages: groqMessages, systemPrompt: systemPrompt)

            if response != nil {
                ai.usage.recordUsage(.chatMessage)
            }

            let assistantMessage = ChatMessage(
                role: .assistant,
                content: response ?? "I'm having trouble connecting right now. Please try again in a moment."
            )
            messages.append(assistantMessage)
            isLoading = false
        }
    }

    private func buildSystemPrompt() -> String {
        var prompt = """
        You are MVM Pulse AI Coach, a premium personalized business and life health advisor. You have deep expertise in business strategy, operations, leadership, personal development, AI integration, and growth. You function as an AI Readiness Officer — helping businesses assess, plan, and execute AI adoption strategies.

        User profile: \(storage.userProfile.role.rawValue) in \(storage.userProfile.industry.rawValue), company size: \(storage.userProfile.companySize.rawValue)
        """

        if let result = storage.latestResult {
            let breakdown = result.categoryScores
                .map { "\($0.category.rawValue): \(Int($0.normalizedScore))%" }
                .joined(separator: ", ")
            prompt += """

            Current Pulse Score: \(Int(result.overallScore))/100 (Level: \(result.level.rawValue))
            Category scores: \(breakdown)
            Strongest: \(result.strongestCategory?.category.rawValue ?? "N/A")
            Weakest: \(result.weakestCategory?.category.rawValue ?? "N/A")
            """
        }

        let completedTasks = storage.roadmap.weeks.flatMap(\.tasks).filter(\.isCompleted).count
        let totalTasks = storage.roadmap.weeks.flatMap(\.tasks).count
        if totalTasks > 0 {
            prompt += "\nRoadmap progress: \(completedTasks)/\(totalTasks) tasks completed."
        }

        prompt += "\nStreak: \(storage.streakData.currentStreak) days."

        if storage.assessmentResults.count >= 2 {
            let prev = storage.assessmentResults[storage.assessmentResults.count - 2]
            let delta = Int((storage.latestResult?.overallScore ?? 0) - prev.overallScore)
            prompt += "\nScore trend: \(delta >= 0 ? "+" : "")\(delta) since last assessment."
        }

        if let result = storage.latestResult {
            let benchmarks = BenchmarkEngine.industryBenchmarks(
                result: result,
                industry: storage.userProfile.industry,
                companySize: storage.userProfile.companySize
            )
            let aboveAvg = benchmarks.filter { $0.delta > 0 }.map { "\($0.category.rawValue): +\(Int($0.delta)) vs avg" }
            let belowAvg = benchmarks.filter { $0.delta <= 0 }.map { "\($0.category.rawValue): \(Int($0.delta)) vs avg" }
            if !aboveAvg.isEmpty {
                prompt += "\nAbove industry average: \(aboveAvg.joined(separator: ", "))"
            }
            if !belowAvg.isEmpty {
                prompt += "\nBelow industry average: \(belowAvg.joined(separator: ", "))"
            }
        }

        prompt += """

        Rules:
        - Be concise (2-4 sentences per response unless they ask for detail)
        - Reference their actual scores, industry benchmarks, and data when relevant
        - Be specific to their role and industry
        - Give actionable advice, not theory
        - Be warm but professional
        - When discussing AI readiness or technology, provide specific tool recommendations and implementation timelines
        - Reference their industry benchmark position when it adds context
        - If they need deeper strategic support, mention that M5CAIRO offers 1-on-1 consultation at m5cairo.com
        - If they ask something outside your scope, gently redirect to business/life health topics
        """

        return prompt
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .assistant {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
                .padding(.top, 2)
            }

            if message.role == .user {
                Spacer(minLength: 48)
            }

            Text(message.content)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.role == .user ? PulseTheme.primaryTeal : Color(.tertiarySystemGroupedBackground))
                .foregroundStyle(message.role == .user ? .white : .primary)
                .clipShape(.rect(cornerRadius: 16))

            if message.role == .assistant {
                Spacer(minLength: 48)
            }
        }
    }
}
