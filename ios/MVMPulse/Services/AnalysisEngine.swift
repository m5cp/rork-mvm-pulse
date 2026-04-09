import Foundation

struct AnalysisEngine {
    static func executiveSummary(result: AssessmentResult, profile: UserProfile) -> String {
        let level = result.level.rawValue
        let strongest = result.strongestCategory?.category.rawValue ?? "unknown"
        let weakest = result.weakestCategory?.category.rawValue ?? "unknown"
        let role = profile.role.rawValue.lowercased()
        let industry = profile.industry.rawValue.lowercased()
        let score = Int(result.overallScore)

        switch result.level {
        case .critical:
            return "Your Pulse Score of \(score) indicates critical gaps across multiple dimensions. As a \(role) in \(industry), your strongest area is \(strongest), but significant work is needed in \(weakest) and other dimensions. The 12-week roadmap below targets your most urgent areas first."
        case .atRisk:
            return "At \(score), your profile shows you are at risk in several key areas. Your foundation in \(strongest) provides something to build on, but \(weakest) requires immediate attention. As a \(role) in \(industry), addressing these gaps now can prevent compounding problems."
        case .developing:
            return "Your score of \(score) places you in the developing range. You have a solid base in \(strongest), and targeted improvement in \(weakest) will yield the most return. As a \(role) in \(industry), the roadmap below is designed to accelerate your trajectory."
        case .strong:
            return "A score of \(score) puts you in strong territory. Your performance in \(strongest) is notable, and refining \(weakest) will push you toward elite status. As a \(role) in \(industry), you are well-positioned for the next level."
        case .elite:
            return "Your Pulse Score of \(score) reflects elite-level performance. Your strength in \(strongest) is exceptional. Even at this level, \(weakest) offers room for optimization. As a \(role) in \(industry), the roadmap focuses on maintaining excellence and pushing boundaries."
        }
    }

    static func categoryAnalysis(category: AssessmentCategory, score: Double) -> CategoryAnalysis {
        let tier: AnalysisTier
        if score < 35 { tier = .low }
        else if score < 65 { tier = .mid }
        else { tier = .high }

        return analysisData[category]?[tier] ?? CategoryAnalysis(
            whatThisMeans: "Analysis not available.",
            painPoints: [],
            opportunities: [],
            potentialImpact: "N/A",
            recommendedNextStep: "Complete a reassessment for updated insights."
        )
    }

    enum AnalysisTier { case low, mid, high }

    struct CategoryAnalysis {
        let whatThisMeans: String
        let painPoints: [String]
        let opportunities: [String]
        let potentialImpact: String
        let recommendedNextStep: String
    }

    static let analysisData: [AssessmentCategory: [AnalysisTier: CategoryAnalysis]] = [
        .financialHealth: [
            .low: CategoryAnalysis(
                whatThisMeans: "Your financial foundation has critical gaps that create ongoing vulnerability. Cash flow visibility is limited and you may be leaving significant value on the table.",
                painPoints: ["Unpredictable cash flow creating constant stress", "Over-reliance on a single revenue source", "No meaningful financial safety net", "Pricing or compensation below market value"],
                opportunities: ["Implement basic cash flow tracking within one week", "Identify one additional revenue stream to develop", "Start building an emergency fund with automatic transfers", "Research market rates for your role and industry"],
                potentialImpact: "Addressing financial health first reduces stress across all other dimensions and creates the stability needed for growth.",
                recommendedNextStep: "Set up a simple cash flow tracking system this week. Know exactly what comes in and goes out."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "Your financial position is functional but not optimized. You have basic systems in place but there is significant room for improvement in forecasting and value capture.",
                painPoints: ["Cash flow tracking is inconsistent or reactive", "Revenue diversification is limited", "Emergency reserves may not cover a major disruption", "Pricing decisions lack data-driven confidence"],
                opportunities: ["Upgrade to weekly financial reviews with projections", "Develop a second income stream strategically", "Build reserves to cover six months of expenses", "Conduct a thorough pricing or compensation analysis"],
                potentialImpact: "Optimizing financial health at this stage compounds quickly. Small improvements in pricing and cash management can yield significant returns.",
                recommendedNextStep: "Audit your current pricing or compensation against three competitors or market benchmarks this week."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "Your financial health is strong with good systems and strategic thinking. You have visibility, diversification, and resilience built into your financial model.",
                painPoints: ["Maintaining discipline during growth phases", "Avoiding complacency with existing revenue streams", "Tax optimization may have room for improvement", "Succession or exit planning may be underdeveloped"],
                opportunities: ["Explore passive income or equity-based compensation", "Implement advanced forecasting with scenario planning", "Review tax strategy with a specialist", "Build long-term wealth through compounding assets"],
                potentialImpact: "At this level, financial optimization is about compounding advantages and building generational wealth or business value.",
                recommendedNextStep: "Review your 12-month financial projections and identify one area where you can increase margin by 10%."
            )
        ],
        .operationsProductivity: [
            .low: CategoryAnalysis(
                whatThisMeans: "Your operations are largely reactive with minimal systems. Most knowledge lives in your head and daily work lacks consistent structure.",
                painPoints: ["No documented processes or standard procedures", "Constant context-switching and reactive firefighting", "Meeting overload with little productive output", "Unable to delegate effectively or at all"],
                opportunities: ["Document your three most repeated workflows this week", "Implement a daily priority-setting ritual", "Audit and eliminate or shorten unnecessary meetings", "Identify one task to delegate or outsource immediately"],
                potentialImpact: "Operational improvements have the highest leverage on your daily experience. Even small systems reduce stress and free up hours.",
                recommendedNextStep: "Write down the three tasks you repeat most often. Document the steps. This is your first SOP."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "You have basic operational habits but significant inefficiencies remain. Some processes are documented but gaps in delegation and meeting management persist.",
                painPoints: ["Documentation exists but is outdated or incomplete", "Delegation happens but with inconsistent quality", "Some recurring bottlenecks remain unresolved", "Time management is reasonable but not optimized"],
                opportunities: ["Update and centralize all existing documentation", "Create a delegation framework with clear ownership", "Implement a quarterly bottleneck review process", "Adopt time-blocking for deep work sessions"],
                potentialImpact: "Moving from mid-level to high operations is where most people see the biggest quality-of-life improvement.",
                recommendedNextStep: "Block two hours of uninterrupted deep work on your calendar every day this week. Protect it completely."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "Your operations are well-systematized with strong delegation and efficient processes. You focus primarily on high-value activities.",
                painPoints: ["Maintaining systems as complexity increases", "Preventing process bloat and over-engineering", "Keeping documentation current with rapid changes", "Finding the next level of operational leverage"],
                opportunities: ["Implement automation for remaining manual processes", "Build redundancy into critical workflows", "Create operational dashboards for real-time visibility", "Explore AI-powered workflow optimization"],
                potentialImpact: "At this level, operational gains come from automation and leverage rather than personal productivity improvements.",
                recommendedNextStep: "Identify your three most time-consuming remaining manual tasks and research automation options."
            )
        ],
        .leadershipStrategy: [
            .low: CategoryAnalysis(
                whatThisMeans: "Strategic direction is unclear and decision-making is reactive. You may be surviving day-to-day without a clear vision for where you are headed.",
                painPoints: ["No clear 12-month plan or quarterly goals", "Decisions are delayed or made without frameworks", "Strategy exists only in your head with no documentation", "Follow-through on commitments is inconsistent"],
                opportunities: ["Define three clear goals for the next 90 days", "Adopt a simple decision-making framework", "Write down your vision and share it with one person", "Implement a weekly review and accountability practice"],
                potentialImpact: "Strategic clarity is a force multiplier. Every other dimension improves when you know where you are going and why.",
                recommendedNextStep: "Write down your top three priorities for the next 90 days. Be specific about what success looks like."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "You have general strategic direction but lack the precision and consistency needed for maximum impact. Decision-making is reasonable but could be faster.",
                painPoints: ["Strategy exists but is not reviewed or updated regularly", "Communication of strategy to stakeholders is inconsistent", "Pivoting when plans fail takes too long", "Accountability systems are informal"],
                opportunities: ["Schedule monthly strategy reviews with clear metrics", "Create a one-page strategic summary to share regularly", "Build in quarterly pivot checkpoints", "Establish formal accountability partnerships or systems"],
                potentialImpact: "Sharpening strategy at this level accelerates progress across every dimension and helps you avoid costly misdirection.",
                recommendedNextStep: "Create a one-page strategic plan with your vision, quarterly goals, and key metrics. Review it weekly."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "Your strategic thinking and execution are strong. You have clear direction, effective decision-making, and strong accountability. You adapt well to change.",
                painPoints: ["Risk of overconfidence in current strategy", "May miss emerging threats or paradigm shifts", "Communicating complex strategy at scale", "Balancing long-term vision with short-term execution"],
                opportunities: ["Develop scenario planning for major risk factors", "Build a strategic advisory group or board", "Implement pre-mortem analysis for major decisions", "Invest in leadership development for your team"],
                potentialImpact: "Elite-level strategy is about anticipation and positioning. The gains here are exponential when executed well.",
                recommendedNextStep: "Run a pre-mortem on your biggest current initiative. What could go wrong, and what would you do about it?"
            )
        ],
        .teamCulture: [
            .low: CategoryAnalysis(
                whatThisMeans: "Professional relationships lack trust and alignment. Conflict is either avoided or destructive, and retention of key people is a challenge.",
                painPoints: ["Low trust and limited psychological safety", "Conflict avoidance or destructive disagreements", "Misaligned priorities among team members", "Difficulty retaining good people or relationships"],
                opportunities: ["Start weekly one-on-one check-ins with key people", "Address one unresolved conflict directly this week", "Define and communicate shared goals clearly", "Invest time in relationship-building outside of work tasks"],
                potentialImpact: "Team and relationship health directly impacts every other dimension. You cannot scale beyond your relationships.",
                recommendedNextStep: "Schedule a candid conversation with one key person about how to improve your working relationship."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "Your team dynamics are functional but not exceptional. Trust exists but may be fragile in some areas. Alignment is present but inconsistent.",
                painPoints: ["Trust varies across different relationships", "Conflict resolution works but takes too long", "Some misalignment on priorities persists", "Development of others is inconsistent"],
                opportunities: ["Implement regular feedback mechanisms", "Create explicit team norms and agreements", "Invest in group skill development", "Build a mentorship or development culture"],
                potentialImpact: "Moving from functional to high-performing team dynamics creates compound returns in productivity and satisfaction.",
                recommendedNextStep: "Ask three key people for honest feedback about one thing you could do better as a collaborator or leader."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "You have strong professional relationships with high trust, effective conflict resolution, and good alignment. People want to work with you.",
                painPoints: ["Maintaining culture during growth or change", "Avoiding groupthink in high-trust environments", "Scaling personal relationships as scope expands", "Succession planning for key relationships"],
                opportunities: ["Formalize your culture and values for scale", "Introduce structured dissent into decision-making", "Build systems for relationship management at scale", "Develop next-generation leaders or collaborators"],
                potentialImpact: "At this level, team and relationship investments create compounding organizational capability.",
                recommendedNextStep: "Identify one person with high potential and create a specific development plan for them."
            )
        ],
        .technologyAI: [
            .low: CategoryAnalysis(
                whatThisMeans: "Technology is significantly underutilized and your digital capabilities are behind. Manual processes dominate and AI adoption has not started.",
                painPoints: ["Most tasks are done manually with no automation", "AI tools are unexplored or unused", "Security practices are inadequate", "Data is not used for decision-making"],
                opportunities: ["Automate one repetitive task this week using existing tools", "Try one AI tool for a real work task", "Set up a password manager and enable two-factor authentication", "Start tracking one key metric consistently"],
                potentialImpact: "Technology is the highest-leverage improvement area. Even basic automation can save hours per week.",
                recommendedNextStep: "Identify the one task you repeat most often manually and find a tool to automate it this week."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "You use technology competently but have significant room for AI integration and automation. Your digital foundation is adequate but not strategic.",
                painPoints: ["Automation is partial with many manual gaps remaining", "AI usage is basic and not integrated into workflows", "Data tracking exists but is not consistently actionable", "Technology stack may have redundancies or gaps"],
                opportunities: ["Audit your tech stack for consolidation and gaps", "Integrate AI into three specific workflows", "Build dashboards for your most important metrics", "Implement a regular technology review process"],
                potentialImpact: "Strategic technology adoption at this stage creates significant competitive advantage and time savings.",
                recommendedNextStep: "Integrate one AI tool into your daily workflow and measure the time saved over two weeks."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "Your technology capabilities are strong with good automation, active AI integration, and data-driven practices. You are ahead of most peers.",
                painPoints: ["Keeping pace with rapid AI evolution", "Managing technology complexity and dependencies", "Training others on advanced tools", "Avoiding technology for technology's sake"],
                opportunities: ["Explore custom AI implementations for unique needs", "Build proprietary data advantages", "Share technology expertise to strengthen your network", "Evaluate emerging technologies for early adoption"],
                potentialImpact: "At this level, technology becomes a moat. Custom implementations and proprietary data create lasting advantages.",
                recommendedNextStep: "Identify one area where a custom AI solution could give you an advantage no off-the-shelf tool provides."
            )
        ],
        .customerMarket: [
            .low: CategoryAnalysis(
                whatThisMeans: "Your market awareness and customer understanding are minimal. You may not have a clear picture of who you serve or how you compare to alternatives.",
                painPoints: ["Target audience is undefined or poorly understood", "No professional brand or market presence", "Conversion of opportunities is inconsistent", "Competitive awareness is minimal"],
                opportunities: ["Define your ideal customer or audience in detail", "Create a basic professional presence online", "Map your conversion process and identify drop-off points", "Research your top three competitors thoroughly"],
                potentialImpact: "Understanding your market is foundational. Every business and career decision improves with better market intelligence.",
                recommendedNextStep: "Write a detailed description of your ideal customer or audience. Include their specific problems and what they value most."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "You have reasonable market awareness but lack the depth needed for strategic positioning. Your brand is developing but conversion could improve.",
                painPoints: ["Customer understanding is general rather than specific", "Brand positioning lacks differentiation", "Feedback collection is inconsistent", "Market monitoring is reactive rather than proactive"],
                opportunities: ["Conduct customer interviews for deeper insight", "Sharpen your unique value proposition", "Implement systematic feedback collection", "Set up competitive monitoring alerts"],
                potentialImpact: "Deepening market understanding at this stage directly improves revenue and professional positioning.",
                recommendedNextStep: "Talk to three customers or contacts this week and ask them what problem you solve best and what you could do better."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "You have strong market awareness, a recognized brand, and effective conversion. You understand your audience deeply and monitor competitive dynamics.",
                painPoints: ["Market position requires constant defense", "Customer expectations are rising continuously", "Emerging competitors may disrupt your position", "Growth may require new market segments"],
                opportunities: ["Build thought leadership content for your niche", "Create community or loyalty programs", "Explore adjacent markets or audience segments", "Develop strategic partnerships for market expansion"],
                potentialImpact: "At this level, market investment is about building moats and creating network effects that compound over time.",
                recommendedNextStep: "Identify one adjacent market or audience segment that could benefit from your expertise and create a plan to test it."
            )
        ],
        .personalWellness: [
            .low: CategoryAnalysis(
                whatThisMeans: "Your personal wellness is significantly compromised. Burnout risk is high and basic health habits need immediate attention.",
                painPoints: ["Chronic exhaustion or energy depletion", "High stress with no effective coping strategies", "No boundaries between work and personal life", "Sleep, exercise, and nutrition all need improvement"],
                opportunities: ["Establish a non-negotiable sleep schedule this week", "Add a 15-minute daily walk or movement practice", "Set one firm boundary between work and personal time", "Identify your top stress trigger and create one coping strategy"],
                potentialImpact: "Personal wellness is the foundation everything else is built on. Improvements here amplify gains in every other dimension.",
                recommendedNextStep: "Set a consistent sleep and wake time for the next seven days. This single change has the highest ROI on your wellbeing."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "Your wellness is functional but inconsistent. You have some good habits but stress management and boundaries need strengthening.",
                painPoints: ["Energy levels are inconsistent throughout the day", "Stress management works sometimes but fails under pressure", "Boundaries exist but are frequently compromised", "Health habits are inconsistent across areas"],
                opportunities: ["Build consistency in your weakest wellness area", "Develop a stress response toolkit for high-pressure moments", "Strengthen boundaries with clear communication", "Create accountability for health commitments"],
                potentialImpact: "Consistent wellness at this stage prevents the backsliding that derails progress in all other dimensions.",
                recommendedNextStep: "Identify your weakest wellness area and commit to one specific daily action for the next 30 days."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "Your personal wellness practices are strong and consistent. You maintain good energy, manage stress effectively, and have clear boundaries.",
                painPoints: ["Maintaining routines during travel or disruption", "Preventing complacency with existing habits", "Deepening fulfillment and meaning in daily work", "Supporting wellness in those around you"],
                opportunities: ["Optimize recovery and stress resilience further", "Explore new wellness practices for continued growth", "Mentor others on sustainable wellness habits", "Align daily activities more closely with purpose and values"],
                potentialImpact: "At this level, wellness optimization is about peak performance and long-term sustainability of your achievements.",
                recommendedNextStep: "Review your daily activities through the lens of purpose alignment. Identify one activity to eliminate or replace."
            )
        ],
        .growthLearning: [
            .low: CategoryAnalysis(
                whatThisMeans: "Learning and growth have stalled. You are operating primarily on existing knowledge without building new capabilities or seeking outside perspective.",
                painPoints: ["No structured learning or development plan", "No mentors or external guidance", "Comfort zone has become a limitation", "No reflection or learning-from-experience practice"],
                opportunities: ["Commit to one learning resource this week", "Identify one person to ask for mentorship", "Take on one small challenge outside your comfort zone", "Start a weekly reflection journal or practice"],
                potentialImpact: "Growth is the engine of long-term success. Without it, all other dimensions eventually plateau or decline.",
                recommendedNextStep: "Choose one book, course, or resource directly relevant to your biggest challenge and start it this week."
            ),
            .mid: CategoryAnalysis(
                whatThisMeans: "You are learning but without the structure and consistency that accelerate growth. Mentorship is informal and comfort zone expansion is occasional.",
                painPoints: ["Learning happens but without clear alignment to goals", "Mentorship is informal and inconsistent", "Comfort zone challenges are infrequent", "Reflection happens but lessons are not always applied"],
                opportunities: ["Create a quarterly learning plan aligned to your goals", "Formalize mentoring relationships with regular meetings", "Schedule monthly stretch challenges", "Implement a structured after-action review process"],
                potentialImpact: "Structured growth at this stage creates compound returns that separate you from peers over time.",
                recommendedNextStep: "Write a learning plan for the next 90 days with specific skills to develop and resources to use."
            ),
            .high: CategoryAnalysis(
                whatThisMeans: "You have strong growth habits with structured learning, active mentorship, and regular comfort zone expansion. You learn from experience systematically.",
                painPoints: ["Diminishing returns on existing learning approaches", "Finding truly challenging growth opportunities", "Balancing learning with execution", "Teaching and developing others while growing yourself"],
                opportunities: ["Seek teaching or mentoring roles to deepen understanding", "Pursue mastery-level challenges in your field", "Build cross-disciplinary knowledge for innovative thinking", "Create or join a mastermind group for peer learning"],
                potentialImpact: "At this level, growth is about mastery, cross-pollination, and building wisdom that compounds across decades.",
                recommendedNextStep: "Identify one area where you could teach others and create a plan to share your expertise this month."
            )
        ]
    ]
}
