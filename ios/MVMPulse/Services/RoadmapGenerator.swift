import Foundation

struct RoadmapGenerator {
    static func generate(from result: AssessmentResult) -> Roadmap {
        let weakest = result.twoWeakestCategories
        var weeks: [RoadmapWeek] = []

        for weekNum in 1...12 {
            let phase: String
            let theme: String
            switch weekNum {
            case 1: phase = "Diagnostic"; theme = "Assess Your Starting Point"
            case 2: phase = "Foundation"; theme = "Build Core Habits"
            case 3: phase = "Foundation"; theme = "Strengthen Your Base"
            case 4: phase = "Foundation"; theme = "Lock In Fundamentals"
            case 5: phase = "Implementation"; theme = "Take Action"
            case 6: phase = "Implementation"; theme = "Build Momentum"
            case 7: phase = "Implementation"; theme = "Expand Your Reach"
            case 8: phase = "Implementation"; theme = "Deepen Your Systems"
            case 9: phase = "Optimization"; theme = "Refine and Improve"
            case 10: phase = "Optimization"; theme = "Measure Progress"
            case 11: phase = "Optimization"; theme = "Iterate and Adjust"
            case 12: phase = "Optimization"; theme = "Plan Your Next Level"
            default: phase = ""; theme = ""
            }

            let tasks = generateTasks(weekNumber: weekNum, categories: weakest, phase: phase)
            let insight = weeklyInsight(weekNumber: weekNum, phase: phase)

            weeks.append(RoadmapWeek(
                id: "week-\(weekNum)",
                weekNumber: weekNum,
                theme: theme,
                phase: phase,
                tasks: tasks,
                isUnlocked: weekNum == 1,
                insightText: insight
            ))
        }

        return Roadmap(weeks: weeks, focusCategories: weakest, generatedDate: Date())
    }

    private static func generateTasks(weekNumber: Int, categories: [AssessmentCategory], phase: String) -> [RoadmapTask] {
        let cat1 = categories.first ?? .financialHealth
        let cat2 = categories.count > 1 ? categories[1] : .operationsProductivity
        let taskSets = taskLibrary[cat1] ?? []
        let taskSets2 = taskLibrary[cat2] ?? []

        var tasks: [RoadmapTask] = []
        let baseIndex = (weekNumber - 1) * 3

        for i in 0..<3 {
            let idx = (baseIndex + i) % taskSets.count
            let template = taskSets[idx]
            tasks.append(RoadmapTask(
                id: "w\(weekNumber)-t\(i+1)",
                title: template.0,
                description: template.1,
                timeEstimate: template.2,
                category: cat1
            ))
        }

        let idx2 = (baseIndex) % taskSets2.count
        let template2 = taskSets2[idx2]
        tasks.append(RoadmapTask(
            id: "w\(weekNumber)-t4",
            title: template2.0,
            description: template2.1,
            timeEstimate: template2.2,
            category: cat2
        ))

        return tasks
    }

    private static func weeklyInsight(weekNumber: Int, phase: String) -> String {
        switch weekNumber {
        case 1: return "This week is about honest assessment. Before you can improve, you need to see clearly where you stand."
        case 2: return "Small consistent actions beat grand plans. Focus on building one habit at a time."
        case 3: return "You are laying the groundwork. These early investments compound over the coming weeks."
        case 4: return "Foundations are nearly set. The habits you build now become automatic in the weeks ahead."
        case 5: return "Time to move from planning to execution. Imperfect action beats perfect planning."
        case 6: return "Momentum is building. Each completed task reinforces your trajectory."
        case 7: return "You are expanding beyond the basics. This is where real differentiation begins."
        case 8: return "Systems are taking shape. Notice how much easier things feel compared to Week 1."
        case 9: return "Refinement is where good becomes great. Look for the 20% of effort driving 80% of results."
        case 10: return "Measure what matters. Data reveals the truth about your progress."
        case 11: return "Iteration is the secret of excellence. Small adjustments compound into significant improvement."
        case 12: return "You have completed a full cycle. Reassess your Pulse Score and plan the next phase of growth."
        default: return "Stay focused on the process. Results follow consistent effort."
        }
    }

    static let taskLibrary: [AssessmentCategory: [(String, String, String)]] = [
        .financialHealth: [
            ("Track all expenses for 7 days", "Record every personal and business expense. Use a simple spreadsheet or notes app. Categorize as fixed, variable, or discretionary.", "10 min/day"),
            ("Calculate your monthly burn rate", "Add up all recurring monthly expenses. Separate essential from optional. Know your exact number.", "15 min"),
            ("Review your pricing or compensation", "Research market rates for your role and industry. Compare your current position. Note specific gaps.", "15 min"),
            ("Build a 90-day cash flow forecast", "Project income and expenses for the next three months. Identify potential shortfalls early.", "15 min"),
            ("Identify one new revenue opportunity", "Brainstorm three potential additional income streams. Research feasibility. Choose one to explore.", "10 min"),
            ("Audit your subscriptions and recurring costs", "List every subscription and recurring payment. Cancel anything unused. Renegotiate where possible.", "10 min"),
            ("Set up automatic savings", "Configure an automatic transfer to a reserve account. Even a small amount builds the habit.", "5 min"),
            ("Review your debt structure", "List all debts with interest rates and terms. Identify the highest-priority payoff target.", "15 min"),
            ("Create a financial dashboard", "Set up a simple weekly review template. Track income, expenses, savings rate, and key metrics.", "15 min"),
            ("Plan your tax optimization", "Review your current tax situation. Identify one deduction or strategy you may be missing.", "10 min"),
            ("Research insurance coverage", "Review your current coverage for gaps. Health, liability, business interruption as applicable.", "10 min"),
            ("Calculate your hourly rate", "Divide your total compensation by hours worked. Is this number where you want it to be?", "10 min")
        ],
        .operationsProductivity: [
            ("Document your top 3 workflows", "Write step-by-step instructions for your three most repeated tasks. Include tools used and decision points.", "15 min"),
            ("Audit your meeting schedule", "Review all meetings from last week. Mark each as essential, reducible, or eliminable. Act on the results.", "10 min"),
            ("Set up a daily priority system", "Choose a method: top 3 priorities, time blocking, or Eisenhower matrix. Use it every morning this week.", "10 min"),
            ("Identify one task to automate", "Find the most repetitive manual task in your week. Research tools or methods to automate it.", "15 min"),
            ("Create a delegation checklist", "List all tasks you currently do that someone else could handle. Rank by impact and ease of delegation.", "10 min"),
            ("Block deep work time", "Schedule two uninterrupted 90-minute blocks this week. Protect them completely from meetings and messages.", "5 min"),
            ("Clean up your digital workspace", "Organize your files, close unnecessary tabs, unsubscribe from noise. A clean environment improves focus.", "15 min"),
            ("Set up a weekly review", "Create a 30-minute weekly review template. Review wins, blockers, upcoming priorities, and lessons learned.", "10 min"),
            ("Reduce notification interruptions", "Audit and disable non-essential notifications. Batch check messages at scheduled intervals.", "10 min"),
            ("Map your energy patterns", "Track your energy levels hourly for three days. Schedule your most important work during peak energy.", "5 min/day"),
            ("Create a project tracker", "Set up a simple system to track all active projects, deadlines, and next actions.", "15 min"),
            ("Eliminate one recurring bottleneck", "Identify the bottleneck that wastes the most time. Implement one fix this week.", "15 min")
        ],
        .leadershipStrategy: [
            ("Write your 90-day goals", "Define three specific measurable goals for the next quarter. Include success criteria and key milestones.", "15 min"),
            ("Create a one-page strategy document", "Summarize your vision, top priorities, key metrics, and current challenges on a single page.", "15 min"),
            ("Practice a decision framework", "Use a structured approach for your next decision. Consider options, criteria, risks, and reversibility.", "10 min"),
            ("Communicate your priorities to one person", "Share your strategic direction with a colleague, partner, or mentor. Get their honest feedback.", "10 min"),
            ("Run a pre-mortem on a current project", "Imagine your biggest initiative has failed. List the most likely reasons. Create mitigation plans.", "15 min"),
            ("Review and adjust your goals", "Check progress against your 90-day goals. Adjust timelines or tactics based on what you have learned.", "10 min"),
            ("Identify your biggest strategic risk", "What is the one thing that could derail your plans? Create a specific contingency response.", "10 min"),
            ("Map your stakeholders", "List everyone affected by your work. Rate your relationship strength. Identify gaps to address.", "10 min"),
            ("Seek external perspective", "Ask someone outside your daily context for their honest assessment of your direction.", "15 min"),
            ("Define your non-negotiables", "List the three things you will not compromise on regardless of pressure. Share them with key people.", "10 min"),
            ("Schedule a strategy review", "Block one hour to step back from execution and think purely about direction and positioning.", "10 min"),
            ("Document a recent decision and outcome", "Write down a recent important decision, your reasoning, and the result. Extract one lesson.", "10 min")
        ],
        .teamCulture: [
            ("Schedule one-on-ones with key people", "Set up 15-minute conversations with your three most important professional relationships this week.", "5 min"),
            ("Ask for honest feedback", "Ask one trusted person what you could do better as a collaborator. Listen without defending.", "10 min"),
            ("Address one unresolved tension", "Identify a relationship with unresolved friction. Have a direct but respectful conversation about it.", "15 min"),
            ("Write down shared goals", "Document the goals you share with your team or key collaborators. Ensure everyone sees the same list.", "10 min"),
            ("Recognize someone's contribution", "Specifically acknowledge one person's recent effort. Be precise about what they did and its impact.", "5 min"),
            ("Create team norms", "Define three explicit expectations for how you work together. Share and get agreement.", "15 min"),
            ("Invest in a relationship", "Spend 15 minutes with someone purely on relationship building. No agenda, no asks.", "15 min"),
            ("Check alignment on priorities", "Ask your team or collaborators to independently list top three priorities. Compare the lists.", "10 min"),
            ("Plan a development conversation", "Identify one person with growth potential. Prepare specific feedback and development suggestions.", "10 min"),
            ("Audit your communication patterns", "Review how and how often you communicate with key people. Identify gaps or overload.", "10 min"),
            ("Practice active listening", "In your next three conversations, focus entirely on understanding before responding.", "5 min"),
            ("Create a conflict resolution plan", "Define a simple process for handling disagreements. Share it before the next conflict arises.", "10 min")
        ],
        .technologyAI: [
            ("Automate one manual task", "Find a task you do manually more than three times per week. Set up automation using Shortcuts, Zapier, or similar.", "15 min"),
            ("Try an AI tool for a real task", "Use ChatGPT, Claude, or another AI tool on an actual work task. Evaluate the time saved and quality.", "15 min"),
            ("Audit your passwords and security", "Set up or update your password manager. Enable two-factor authentication on your five most important accounts.", "15 min"),
            ("Set up one data dashboard", "Choose your most important metric. Create a simple way to track it weekly.", "15 min"),
            ("Review your tech stack", "List all tools and subscriptions. Rate each as essential, useful, or redundant. Consolidate where possible.", "10 min"),
            ("Learn one AI prompt technique", "Research and practice one prompting method that improves your AI tool results.", "10 min"),
            ("Back up your critical data", "Ensure all important files are backed up in at least two locations. Set up automatic backup.", "10 min"),
            ("Explore a workflow integration", "Find two tools you use separately that could be connected. Set up the integration.", "15 min"),
            ("Update your software", "Update all apps, operating systems, and tools to current versions. Remove unused applications.", "10 min"),
            ("Research one emerging tool", "Spend 10 minutes exploring one new tool or technology relevant to your work. Assess its potential.", "10 min"),
            ("Create an AI use case list", "Brainstorm five specific tasks where AI could save you time. Prioritize by impact.", "10 min"),
            ("Test a new productivity tool", "Try one productivity tool you have been curious about. Use it for a real task and evaluate.", "15 min")
        ],
        .customerMarket: [
            ("Define your ideal customer", "Write a detailed profile of your best customer or audience member. Include problems, values, and behaviors.", "15 min"),
            ("Research three competitors", "Identify three direct competitors. Note their strengths, weaknesses, pricing, and positioning.", "15 min"),
            ("Map your conversion process", "Draw the path from first contact to purchase or result. Identify where people drop off.", "10 min"),
            ("Collect feedback from one customer", "Reach out to one person who has worked with you. Ask what they valued most and what could improve.", "10 min"),
            ("Update your professional presence", "Review and improve one element of your online presence. LinkedIn, website, or portfolio.", "15 min"),
            ("Identify your unique value", "Write one sentence that explains why someone should choose you over alternatives. Test it with others.", "10 min"),
            ("Set up a competitive alert", "Create Google Alerts or follow competitors to stay aware of market changes.", "5 min"),
            ("Analyze a lost opportunity", "Review one deal or opportunity you lost recently. Identify the specific reason and one improvement.", "10 min"),
            ("Test a new outreach approach", "Try one new method to reach potential customers or contacts this week. Measure the response.", "15 min"),
            ("Review your pricing strategy", "Compare your pricing to market rates. Identify one adjustment that could improve your position.", "10 min"),
            ("Create a customer success story", "Document one specific result you delivered. Include the problem, solution, and measurable outcome.", "15 min"),
            ("Plan a content piece", "Outline one article, post, or resource that would demonstrate your expertise to your target audience.", "10 min")
        ],
        .personalWellness: [
            ("Set a consistent sleep schedule", "Choose a bedtime and wake time. Follow it every day this week including weekends.", "5 min"),
            ("Add a 15-minute daily walk", "Walk for 15 minutes at the same time each day. No phone, no podcast. Just movement and observation.", "15 min"),
            ("Identify your top stress trigger", "Write down the situation that causes you the most stress. Design one specific coping response.", "10 min"),
            ("Set one firm boundary", "Choose one boundary between work and personal life. Communicate it clearly to the relevant people.", "10 min"),
            ("Practice a 5-minute breathing exercise", "Try box breathing or 4-7-8 breathing once daily. Use it as a reset between tasks.", "5 min"),
            ("Plan your meals for three days", "Prepare a simple meal plan. Focus on whole foods and consistent eating times.", "10 min"),
            ("Reduce screen time before bed", "Stop all screens 30 minutes before your target bedtime. Read, stretch, or journal instead.", "5 min"),
            ("Do a energy audit", "Rate your energy 1 to 5 at four points today. Identify what boosted and what drained your energy.", "5 min"),
            ("Schedule recovery time", "Block 30 minutes of intentional rest this week. Not entertainment. Genuine rest and recovery.", "5 min"),
            ("Connect with someone important", "Spend 15 minutes with a friend or family member with full attention. No devices.", "15 min"),
            ("Try a new physical activity", "Do something physically active that you normally would not. A class, sport, or exercise variation.", "15 min"),
            ("Write three things you are grateful for", "At the end of the day, write three specific things from today that went well or that you appreciate.", "5 min")
        ],
        .growthLearning: [
            ("Start one learning resource", "Choose a book, course, podcast, or article relevant to your biggest challenge. Begin it today.", "15 min"),
            ("Identify a potential mentor", "List three people you admire who could offer guidance. Research how to approach one of them.", "10 min"),
            ("Do one thing outside your comfort zone", "Take one small professional risk this week. A new approach, a difficult conversation, or a new skill.", "10 min"),
            ("Write a weekly reflection", "Spend 10 minutes reviewing your week. What worked? What did you learn? What will you do differently?", "10 min"),
            ("Teach someone one thing you know", "Share a skill or insight with a colleague. Teaching deepens your own understanding.", "15 min"),
            ("Study one new concept", "Spend 15 minutes learning about one idea relevant to your field that you do not fully understand.", "15 min"),
            ("Review your goals against your skills", "Map the skills needed for your goals. Identify the biggest gap and plan to address it.", "10 min"),
            ("Seek feedback on your growth", "Ask someone who knows you well how they have seen you change in the past year.", "10 min"),
            ("Attend a virtual event or webinar", "Find one online event in your field. Attend and take notes on key takeaways.", "15 min"),
            ("Read about a field outside your own", "Spend 15 minutes learning about a different industry or discipline. Look for cross-pollination ideas.", "15 min"),
            ("Set a 30-day learning challenge", "Choose one specific skill to improve over 30 days. Define daily practice and success criteria.", "10 min"),
            ("Document your expertise", "Write down the top five things you know better than most people. Consider how to leverage them.", "10 min")
        ]
    ]
}
