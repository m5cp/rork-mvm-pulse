import Foundation

struct QuestionBank {
    static let allQuestions: [AssessmentQuestion] = {
        var questions: [AssessmentQuestion] = []
        questions.append(contentsOf: financialHealthQuestions)
        questions.append(contentsOf: operationsQuestions)
        questions.append(contentsOf: leadershipQuestions)
        questions.append(contentsOf: teamCultureQuestions)
        questions.append(contentsOf: technologyQuestions)
        questions.append(contentsOf: customerMarketQuestions)
        questions.append(contentsOf: personalWellnessQuestions)
        questions.append(contentsOf: growthLearningQuestions)
        return questions
    }()

    static let coreQuestions: [AssessmentQuestion] = allQuestions.filter(\.isCore)

    static let deepDiveQuestions: [AssessmentQuestion] = allQuestions.filter { !$0.isCore }

    static func questions(for category: AssessmentCategory) -> [AssessmentQuestion] {
        allQuestions.filter { $0.category == category }
    }

    static func coreQuestions(for category: AssessmentCategory) -> [AssessmentQuestion] {
        coreQuestions.filter { $0.category == category }
    }

    static func deepDiveQuestions(for category: AssessmentCategory) -> [AssessmentQuestion] {
        deepDiveQuestions.filter { $0.category == category }
    }

    static func deepDiveQuestions(for categories: [AssessmentCategory]) -> [AssessmentQuestion] {
        deepDiveQuestions.filter { categories.contains($0.category) }
    }

    private static func makeOptions(_ texts: [(String, Int)]) -> [AnswerOption] {
        texts.map { AnswerOption(id: UUID().uuidString, text: $0.0, score: $0.1) }
    }

    static let financialHealthQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "fh1", category: .financialHealth, text: "How well do you understand your current cash flow position?", options: makeOptions([
            ("I rarely check and often face surprise shortfalls", 1),
            ("I review occasionally but miss important patterns", 2),
            ("I track monthly and have a general sense of cash flow", 3),
            ("I review weekly with clear forecasting for the next quarter", 4),
            ("I have real-time visibility with automated tracking and 12-month projections", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "fh2", category: .financialHealth, text: "How diversified are your income or revenue streams?", options: makeOptions([
            ("I depend entirely on a single source of income", 1),
            ("I have one primary source with occasional side income", 2),
            ("I have two to three active income streams", 3),
            ("I have multiple streams with intentional diversification", 4),
            ("I have a balanced portfolio of streams with passive income components", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "fh3", category: .financialHealth, text: "How prepared are you for an unexpected financial disruption?", options: makeOptions([
            ("I would be in serious trouble within a week", 1),
            ("I could manage about a month before real problems hit", 2),
            ("I have roughly three months of reserves available", 3),
            ("I have six months of expenses covered with a clear contingency plan", 4),
            ("I have over a year of runway and insurance coverage for major risks", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "fh4", category: .financialHealth, text: "How effectively do you manage debt and financial obligations?", options: makeOptions([
            ("Debt is overwhelming and I struggle to meet minimum payments", 1),
            ("I manage payments but debt is growing or stagnant", 2),
            ("I have a repayment plan and am making steady progress", 3),
            ("Debt is well-managed and strategically structured", 4),
            ("I use leverage intentionally and all obligations are optimized", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "fh5", category: .financialHealth, text: "How confident are you in your pricing, compensation, or financial value capture?", options: makeOptions([
            ("I undercharge significantly and leave money on the table", 1),
            ("I suspect I am undervalued but have not analyzed it", 2),
            ("My pricing or compensation is roughly market-rate", 3),
            ("I have data-backed pricing and regularly review my position", 4),
            ("I command premium rates based on clear value differentiation", 5)
        ]), isCore: false)
    ]

    static let operationsQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "op1", category: .operationsProductivity, text: "How well-defined are your daily priorities and workflow?", options: makeOptions([
            ("I start each day reacting to whatever comes up", 1),
            ("I have a loose sense of priorities but get sidetracked often", 2),
            ("I plan my days and complete most key tasks", 3),
            ("I have a structured system that prioritizes high-impact work", 4),
            ("My workflow is optimized with time blocks, reviews, and minimal wasted effort", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "op2", category: .operationsProductivity, text: "How much of your work is documented or systematized?", options: makeOptions([
            ("Almost nothing is documented and everything depends on me", 1),
            ("A few things are written down but most knowledge is in my head", 2),
            ("Key processes are documented but need regular updates", 3),
            ("Most workflows have clear SOPs and are repeatable by others", 4),
            ("Comprehensive systems exist with automation and continuous improvement", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "op3", category: .operationsProductivity, text: "How effectively do you delegate or outsource tasks?", options: makeOptions([
            ("I do almost everything myself even when I should not", 1),
            ("I delegate occasionally but often redo the work myself", 2),
            ("I delegate routine tasks but keep too much on my plate", 3),
            ("I delegate strategically and trust my team or contractors", 4),
            ("I focus only on my highest-value activities with everything else delegated", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "op4", category: .operationsProductivity, text: "How effectively do you manage meetings and communication overhead?", options: makeOptions([
            ("Meetings consume most of my day with little productive output", 1),
            ("I attend too many meetings but have started to push back", 2),
            ("I manage meeting load reasonably but still waste some time", 3),
            ("Meetings are purposeful with agendas and clear outcomes", 4),
            ("Communication is streamlined with async-first practices and minimal meetings", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "op5", category: .operationsProductivity, text: "How well do you handle bottlenecks and operational friction?", options: makeOptions([
            ("The same problems keep recurring and nothing changes", 1),
            ("I notice bottlenecks but rarely fix the root cause", 2),
            ("I address major bottlenecks when they become urgent", 3),
            ("I proactively identify and resolve friction points quarterly", 4),
            ("I have a continuous improvement process that prevents most bottlenecks", 5)
        ]), isCore: false)
    ]

    static let leadershipQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "ls1", category: .leadershipStrategy, text: "How clear is your vision for the next 12 months?", options: makeOptions([
            ("I am just trying to get through the week", 1),
            ("I have a vague sense of direction but nothing concrete", 2),
            ("I have general goals but lack a structured plan to achieve them", 3),
            ("I have clear quarterly milestones aligned with a 12-month vision", 4),
            ("I have a detailed strategic plan with metrics, reviews, and contingencies", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ls2", category: .leadershipStrategy, text: "How well do you make decisions under uncertainty?", options: makeOptions([
            ("I avoid decisions and hope problems resolve themselves", 1),
            ("I agonize over decisions and often second-guess myself", 2),
            ("I make reasonable decisions but sometimes too slowly", 3),
            ("I use frameworks and data to make timely decisions", 4),
            ("I am decisive with a proven decision-making process and post-decision reviews", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ls3", category: .leadershipStrategy, text: "How strong is your personal accountability and follow-through?", options: makeOptions([
            ("I set goals but rarely follow through on them", 1),
            ("I complete about half of what I commit to", 2),
            ("I generally follow through but sometimes let things slip", 3),
            ("I have strong follow-through with accountability systems in place", 4),
            ("I model extreme accountability and have never missed a critical commitment", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ls4", category: .leadershipStrategy, text: "How effectively do you communicate your strategy to others?", options: makeOptions([
            ("I keep my plans mostly to myself", 1),
            ("I share plans occasionally but people seem confused", 2),
            ("Key stakeholders generally understand the direction", 3),
            ("I communicate strategy regularly with clear supporting context", 4),
            ("Everyone involved can articulate the strategy and their role in it", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "ls5", category: .leadershipStrategy, text: "How well do you adapt when your initial plan is not working?", options: makeOptions([
            ("I stick to failing plans too long or abandon them entirely", 1),
            ("I eventually pivot but usually after significant losses", 2),
            ("I adjust course when data clearly shows a problem", 3),
            ("I build in regular checkpoints and pivot quickly when needed", 4),
            ("I run small experiments and iterate continuously based on results", 5)
        ]), isCore: false)
    ]

    static let teamCultureQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "tc1", category: .teamCulture, text: "How would you describe the trust level in your professional relationships?", options: makeOptions([
            ("There is significant distrust or toxicity in my work environment", 1),
            ("Trust is low and people tend to protect their own interests", 2),
            ("Trust is moderate but fragile in some relationships", 3),
            ("There is generally strong trust with open communication", 4),
            ("Deep trust exists with psychological safety and honest feedback", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "tc2", category: .teamCulture, text: "How aligned are the people around you with shared goals?", options: makeOptions([
            ("Everyone seems to be working toward different things", 1),
            ("Some alignment exists but priorities frequently clash", 2),
            ("Most people understand the shared goals but execution varies", 3),
            ("Strong alignment with regular calibration on priorities", 4),
            ("Complete alignment with autonomous execution toward shared objectives", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "tc3", category: .teamCulture, text: "How well do you invest in the growth of people around you?", options: makeOptions([
            ("I do not have time or energy to develop others", 1),
            ("I occasionally mentor or help but it is not consistent", 2),
            ("I make some effort to help key people grow", 3),
            ("I regularly invest in developing my team or mentees", 4),
            ("I have a structured development approach and see people consistently grow", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "tc4", category: .teamCulture, text: "How effectively does your team or network handle conflict?", options: makeOptions([
            ("Conflict is avoided entirely or becomes destructive", 1),
            ("Conflict usually creates lasting tension", 2),
            ("We handle conflict okay but it takes too long to resolve", 3),
            ("We address conflict directly and reach resolution efficiently", 4),
            ("Healthy debate is encouraged and conflicts lead to better outcomes", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "tc5", category: .teamCulture, text: "How well do you retain talent or maintain key professional relationships?", options: makeOptions([
            ("Good people leave regularly and relationships are transactional", 1),
            ("Retention is a challenge and I lose important contacts", 2),
            ("I keep most key relationships but some slip away", 3),
            ("I actively maintain my network and retain strong team members", 4),
            ("People seek me out and key relationships are deep and lasting", 5)
        ]), isCore: false)
    ]

    static let technologyQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "ta1", category: .technologyAI, text: "How well do you leverage technology to automate repetitive tasks?", options: makeOptions([
            ("I do almost everything manually that could be automated", 1),
            ("I use basic tools but many processes are still manual", 2),
            ("I have some automation but significant opportunities remain", 3),
            ("Most repetitive tasks are automated with integrated tools", 4),
            ("I have a comprehensive automation strategy that saves significant time weekly", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ta2", category: .technologyAI, text: "How prepared are you to integrate AI into your work or business?", options: makeOptions([
            ("I have not explored AI at all and do not see the relevance", 1),
            ("I have heard about AI tools but have not tried them", 2),
            ("I use basic AI tools like ChatGPT occasionally", 3),
            ("I have integrated AI into several workflows with measurable impact", 4),
            ("AI is a core part of my strategy with custom implementations and ongoing experimentation", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ta3", category: .technologyAI, text: "How effectively do you use data to inform decisions?", options: makeOptions([
            ("I make decisions based on gut feeling with no data", 1),
            ("I occasionally look at numbers but do not track consistently", 2),
            ("I track key metrics but do not always act on them", 3),
            ("I have dashboards and regularly use data to guide decisions", 4),
            ("Data-driven decision making is embedded in everything I do", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "ta4", category: .technologyAI, text: "How secure and protected is your digital infrastructure?", options: makeOptions([
            ("I reuse passwords and have no security measures in place", 1),
            ("I have basic passwords but no backup or recovery plan", 2),
            ("I use a password manager and have basic security practices", 3),
            ("I have strong security including 2FA, backups, and encryption", 4),
            ("I have enterprise-grade security with regular audits and incident response plans", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "ta5", category: .technologyAI, text: "How current is your technology stack and digital skills?", options: makeOptions([
            ("I use outdated tools and my skills are years behind", 1),
            ("My setup works but I know there are better options available", 2),
            ("I upgrade periodically and learn new tools when needed", 3),
            ("I stay current and regularly evaluate new technologies", 4),
            ("I am on the cutting edge and often adopt tools before they become mainstream", 5)
        ]), isCore: false)
    ]

    static let customerMarketQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "cm1", category: .customerMarket, text: "How well do you understand your target audience or customer base?", options: makeOptions([
            ("I am not sure who my ideal customer or audience is", 1),
            ("I have a general idea but have not validated it", 2),
            ("I know my audience and have some data to support it", 3),
            ("I have detailed personas backed by research and feedback", 4),
            ("I have deep customer understanding with ongoing research and direct relationships", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "cm2", category: .customerMarket, text: "How effectively do you convert interest into revenue or results?", options: makeOptions([
            ("I struggle to close deals or convert interest into outcomes", 1),
            ("My conversion is inconsistent and I lose many opportunities", 2),
            ("I convert at a reasonable rate but know I could improve", 3),
            ("I have a proven conversion process with good results", 4),
            ("My conversion is optimized with data, automation, and continuous improvement", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "cm3", category: .customerMarket, text: "How aware are you of competitive threats and market changes?", options: makeOptions([
            ("I have no idea what competitors or market trends look like", 1),
            ("I am vaguely aware of competition but do not track it", 2),
            ("I check in on competitors and trends periodically", 3),
            ("I actively monitor the competitive landscape and adjust strategy", 4),
            ("I anticipate market shifts and position ahead of competitors", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "cm4", category: .customerMarket, text: "How strong is your professional reputation or brand?", options: makeOptions([
            ("I have no brand presence or professional reputation to speak of", 1),
            ("Some people know what I do but I have no intentional positioning", 2),
            ("I have a developing reputation in my immediate network", 3),
            ("I am well-known in my niche with a clear professional brand", 4),
            ("I am a recognized authority with inbound opportunities and referrals", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "cm5", category: .customerMarket, text: "How well do you gather and act on feedback?", options: makeOptions([
            ("I never ask for feedback and do not know what people think", 1),
            ("I occasionally get feedback but rarely act on it", 2),
            ("I collect feedback periodically and make some adjustments", 3),
            ("I have structured feedback loops and regularly implement changes", 4),
            ("Feedback is deeply integrated into my improvement process with rapid iteration", 5)
        ]), isCore: false)
    ]

    static let personalWellnessQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "pw1", category: .personalWellness, text: "How would you rate your typical energy level throughout the day?", options: makeOptions([
            ("I am exhausted most of the time and struggle to function", 1),
            ("My energy is low and I rely on caffeine to get through", 2),
            ("My energy is okay but I have significant afternoon crashes", 3),
            ("I maintain good energy with occasional dips I manage well", 4),
            ("I have consistently high energy optimized through sleep, nutrition, and exercise", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "pw2", category: .personalWellness, text: "How well do you manage stress and prevent burnout?", options: makeOptions([
            ("I am burned out or very close to it", 1),
            ("Stress is high and I have no effective coping strategies", 2),
            ("I manage stress okay but feel overwhelmed regularly", 3),
            ("I have healthy stress management practices that usually work", 4),
            ("I proactively manage stress with boundaries, recovery time, and resilience practices", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "pw3", category: .personalWellness, text: "How consistent are your sleep, exercise, and nutrition habits?", options: makeOptions([
            ("All three are neglected and I know it is hurting me", 1),
            ("I try but am inconsistent across the board", 2),
            ("One or two areas are decent but others need work", 3),
            ("I have solid habits in all three with occasional lapses", 4),
            ("I maintain optimized routines for sleep, exercise, and nutrition consistently", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "pw4", category: .personalWellness, text: "How strong are your boundaries between work and personal life?", options: makeOptions([
            ("There are no boundaries and work consumes everything", 1),
            ("I try to set boundaries but constantly break them", 2),
            ("I have some boundaries but they are inconsistent", 3),
            ("I maintain clear boundaries with rare exceptions", 4),
            ("My boundaries are strong and non-negotiable with full support from others", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "pw5", category: .personalWellness, text: "How fulfilling do you find your current work and daily activities?", options: makeOptions([
            ("I dread most of what I do and feel trapped", 1),
            ("I get through the day but find little satisfaction", 2),
            ("Some parts are fulfilling but much feels like a grind", 3),
            ("I find genuine meaning and satisfaction in most of my work", 4),
            ("I am deeply fulfilled and my work aligns with my purpose and values", 5)
        ]), isCore: false)
    ]

    static let growthLearningQuestions: [AssessmentQuestion] = [
        AssessmentQuestion(id: "gl1", category: .growthLearning, text: "How intentional is your approach to learning and skill development?", options: makeOptions([
            ("I have not learned anything new in months", 1),
            ("I learn reactively when forced to by circumstances", 2),
            ("I read or take courses occasionally without a plan", 3),
            ("I have a structured learning plan aligned with my goals", 4),
            ("I invest significantly in learning with mentors, courses, and deliberate practice", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "gl2", category: .growthLearning, text: "How often do you step outside your comfort zone professionally?", options: makeOptions([
            ("I avoid anything uncomfortable and stick to what I know", 1),
            ("I take small risks occasionally but usually play it safe", 2),
            ("I challenge myself periodically with new projects or roles", 3),
            ("I regularly take on stretch assignments and new challenges", 4),
            ("I systematically push my boundaries and view discomfort as a growth signal", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "gl3", category: .growthLearning, text: "How well do you reflect on and learn from your experiences?", options: makeOptions([
            ("I repeat the same mistakes and rarely reflect", 1),
            ("I think about what went wrong but do not change behavior", 2),
            ("I reflect occasionally and sometimes apply the lessons", 3),
            ("I have regular reflection practices and actively apply insights", 4),
            ("I maintain structured review processes that continuously improve my performance", 5)
        ]), isCore: true),
        AssessmentQuestion(id: "gl4", category: .growthLearning, text: "How well do you seek out and act on mentorship or expert guidance?", options: makeOptions([
            ("I have no mentors and do not seek outside perspective", 1),
            ("I occasionally ask for advice but do not have consistent guidance", 2),
            ("I have informal mentors I reach out to sometimes", 3),
            ("I have active mentoring relationships that I value", 4),
            ("I have a personal board of advisors I consult regularly on key decisions", 5)
        ]), isCore: false),
        AssessmentQuestion(id: "gl5", category: .growthLearning, text: "How invested are you in building long-term career or business assets?", options: makeOptions([
            ("I am focused only on surviving day to day", 1),
            ("I think about the future but take no concrete steps", 2),
            ("I am building some assets but without a clear strategy", 3),
            ("I invest regularly in assets that compound over time", 4),
            ("I have a clear long-term asset strategy with diversified investments in skills, relationships, and equity", 5)
        ]), isCore: false)
    ]
}
