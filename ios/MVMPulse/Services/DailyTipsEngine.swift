import Foundation

struct DailyTip: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let icon: String
    let category: AssessmentCategory?
    let actionLabel: String?
}

struct DailyTipsEngine {
    static func tipOfTheDay(for result: AssessmentResult?, streakData: StreakData) -> DailyTip {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1

        guard let result else {
            return generalTips[dayOfYear % generalTips.count]
        }

        let weakest = result.twoWeakestCategories
        let allTips = categoryTips(for: weakest, score: result.overallScore) + streakTips(streakData: streakData)
        let index = dayOfYear % max(allTips.count, 1)
        return allTips.isEmpty ? generalTips[dayOfYear % generalTips.count] : allTips[index]
    }

    private static func categoryTips(for categories: [AssessmentCategory], score: Double) -> [DailyTip] {
        var tips: [DailyTip] = []
        for cat in categories {
            tips.append(contentsOf: tipsForCategory(cat))
        }
        if score < 35 {
            tips.append(DailyTip(
                id: "momentum",
                title: "Start With One Thing",
                body: "Don't try to fix everything at once. Pick your single lowest-scoring category and give it 10 focused minutes today.",
                icon: "scope",
                category: nil,
                actionLabel: "View Roadmap"
            ))
        }
        return tips
    }

    private static func streakTips(streakData: StreakData) -> [DailyTip] {
        var tips: [DailyTip] = []
        if streakData.currentStreak >= 7 {
            tips.append(DailyTip(
                id: "streak_strong",
                title: "Momentum is Your Superpower",
                body: "A \(streakData.currentStreak)-day streak means you've built a real habit. Research shows it takes 66 days on average to make a behavior automatic.",
                icon: "flame.fill",
                category: nil,
                actionLabel: nil
            ))
        }
        if streakData.streakBroken {
            tips.append(DailyTip(
                id: "streak_restart",
                title: "Fresh Start Effect",
                body: "Missing a day is normal. Studies show people who restart quickly after a break build stronger long-term habits than those with perfect streaks.",
                icon: "arrow.counterclockwise",
                category: nil,
                actionLabel: nil
            ))
        }
        return tips
    }

    private static func tipsForCategory(_ category: AssessmentCategory) -> [DailyTip] {
        switch category {
        case .financialHealth:
            return [
                DailyTip(id: "fin1", title: "Track Before You Optimize", body: "Spend 5 minutes reviewing your last week's expenses. You can't improve what you don't measure.", icon: "dollarsign.circle.fill", category: .financialHealth, actionLabel: nil),
                DailyTip(id: "fin2", title: "The 1% Price Test", body: "Could you raise your prices by 1% without losing customers? Most businesses undercharge by 15-25%.", icon: "chart.bar.fill", category: .financialHealth, actionLabel: nil),
                DailyTip(id: "fin3", title: "Emergency Fund Check", body: "Do you have 3-6 months of runway? If not, automate a small weekly transfer today.", icon: "shield.fill", category: .financialHealth, actionLabel: nil),
            ]
        case .operationsProductivity:
            return [
                DailyTip(id: "ops1", title: "The 2-Minute Rule", body: "If a task takes less than 2 minutes, do it now. If it takes more, schedule it. This alone can clear 30% of your mental load.", icon: "timer", category: .operationsProductivity, actionLabel: nil),
                DailyTip(id: "ops2", title: "Document One Process", body: "Pick the task you repeat most often and write down the steps. Your future self will thank you.", icon: "doc.text.fill", category: .operationsProductivity, actionLabel: nil),
                DailyTip(id: "ops3", title: "Batch Similar Tasks", body: "Group emails, calls, and admin into blocks. Context-switching costs 23 minutes of recovery each time.", icon: "square.stack.3d.up.fill", category: .operationsProductivity, actionLabel: nil),
            ]
        case .leadershipStrategy:
            return [
                DailyTip(id: "lead1", title: "Write Your Weekly Top 3", body: "Before the week starts, write down the 3 most important things you need to accomplish. Everything else is noise.", icon: "flag.fill", category: .leadershipStrategy, actionLabel: nil),
                DailyTip(id: "lead2", title: "Decide Faster", body: "For reversible decisions, move in under 5 minutes. Save your deliberation for the irreversible ones.", icon: "bolt.fill", category: .leadershipStrategy, actionLabel: nil),
                DailyTip(id: "lead3", title: "Review Your Vision", body: "When was the last time you reviewed your 12-month plan? Re-read it today and note what's changed.", icon: "eye.fill", category: .leadershipStrategy, actionLabel: nil),
            ]
        case .teamCulture:
            return [
                DailyTip(id: "team1", title: "One Genuine Compliment", body: "Recognize someone today for something specific they did well. Specific praise builds trust faster than general encouragement.", icon: "person.2.fill", category: .teamCulture, actionLabel: nil),
                DailyTip(id: "team2", title: "Ask, Don't Tell", body: "In your next conversation, ask 'What do you think?' before sharing your opinion. The best leaders listen first.", icon: "bubble.left.fill", category: .teamCulture, actionLabel: nil),
                DailyTip(id: "team3", title: "Address Tension Early", body: "Is there an unresolved conflict you've been avoiding? Small frictions become major issues if ignored.", icon: "hand.raised.fill", category: .teamCulture, actionLabel: nil),
            ]
        case .technologyAI:
            return [
                DailyTip(id: "tech1", title: "Automate One Thing", body: "What task did you repeat manually this week? Spend 10 minutes finding a tool that does it automatically.", icon: "cpu.fill", category: .technologyAI, actionLabel: nil),
                DailyTip(id: "tech2", title: "AI as a Thinking Partner", body: "Use an AI tool to brainstorm solutions to your biggest current challenge. The quality of your prompts determines the quality of output.", icon: "sparkles", category: .technologyAI, actionLabel: nil),
                DailyTip(id: "tech3", title: "Security Quick Check", body: "When did you last update your passwords? Enable 2FA on your three most important accounts today.", icon: "lock.shield.fill", category: .technologyAI, actionLabel: nil),
            ]
        case .customerMarket:
            return [
                DailyTip(id: "cust1", title: "Talk to One Customer", body: "Reach out to one customer or client today. Ask what you could do better. Direct feedback beats assumptions.", icon: "person.wave.2.fill", category: .customerMarket, actionLabel: nil),
                DailyTip(id: "cust2", title: "Study a Competitor", body: "Spend 5 minutes looking at what your top competitor is doing differently. What can you learn?", icon: "magnifyingglass", category: .customerMarket, actionLabel: nil),
                DailyTip(id: "cust3", title: "Refine Your Pitch", body: "Can you explain what you do in one sentence? Practice it today until it feels natural.", icon: "text.bubble.fill", category: .customerMarket, actionLabel: nil),
            ]
        case .personalWellness:
            return [
                DailyTip(id: "well1", title: "Move for 10 Minutes", body: "A short walk improves focus for up to 2 hours. Step away from the screen right now.", icon: "figure.walk", category: .personalWellness, actionLabel: nil),
                DailyTip(id: "well2", title: "Set a Hard Stop", body: "Pick an end time for work today and honor it. Recovery is not laziness—it's strategy.", icon: "moon.fill", category: .personalWellness, actionLabel: nil),
                DailyTip(id: "well3", title: "Hydration Check", body: "Have you had enough water today? Dehydration reduces cognitive performance by up to 25%.", icon: "drop.fill", category: .personalWellness, actionLabel: nil),
            ]
        case .growthLearning:
            return [
                DailyTip(id: "grow1", title: "Learn for 15 Minutes", body: "Read one article, watch one tutorial, or listen to one podcast episode related to your biggest challenge.", icon: "book.fill", category: .growthLearning, actionLabel: nil),
                DailyTip(id: "grow2", title: "Teach What You Know", body: "Explain something you're good at to someone else today. Teaching deepens understanding more than studying.", icon: "person.and.arrow.left.and.arrow.right", category: .growthLearning, actionLabel: nil),
                DailyTip(id: "grow3", title: "Comfort Zone Push", body: "Do one small thing today that makes you slightly uncomfortable. Growth happens at the edge of comfort.", icon: "arrow.up.right.circle.fill", category: .growthLearning, actionLabel: nil),
            ]
        }
    }

    private static let generalTips: [DailyTip] = [
        DailyTip(id: "gen1", title: "Progress Over Perfection", body: "Done is better than perfect. Ship the thing, learn from the feedback, iterate.", icon: "checkmark.circle.fill", category: nil, actionLabel: nil),
        DailyTip(id: "gen2", title: "Energy Management > Time Management", body: "Track when you have the most energy and protect those hours for your most important work.", icon: "bolt.heart.fill", category: nil, actionLabel: nil),
        DailyTip(id: "gen3", title: "The Power of Saying No", body: "Every yes is a no to something else. Be intentional about where you spend your time today.", icon: "hand.raised.fill", category: nil, actionLabel: nil),
        DailyTip(id: "gen4", title: "Reflect on Your Week", body: "What went well? What didn't? What will you do differently? 5 minutes of reflection beats 5 hours of repetition.", icon: "text.book.closed.fill", category: nil, actionLabel: nil),
    ]
}
