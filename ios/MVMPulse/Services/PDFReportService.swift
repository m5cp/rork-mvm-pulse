import UIKit
import PDFKit

struct PDFReportService {
    static func generateReport(result: AssessmentResult, profile: UserProfile, roadmap: Roadmap) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            drawCoverPage(context: context, result: result, profile: profile, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin)
            drawScoreBreakdown(context: context, result: result, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawIndustryBenchmarks(context: context, result: result, profile: profile, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawCategoryAnalysis(context: context, result: result, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawRecommendations(context: context, result: result, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawRoadmapOverview(context: context, roadmap: roadmap, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawWhatsNextPage(context: context, result: result, profile: profile, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawDisclaimerPage(context: context, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
        }

        return data
    }

    private static func drawCoverPage(context: UIGraphicsPDFRendererContext, result: AssessmentResult, profile: UserProfile, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat) {
        context.beginPage()
        let tealColor = UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)
        let darkColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)

        let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 36, weight: .bold), .foregroundColor: darkColor]
        let subtitleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .regular), .foregroundColor: UIColor.gray]
        let scoreAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 72, weight: .heavy), .foregroundColor: tealColor]
        let levelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .semibold), .foregroundColor: tealColor]

        "MVM PULSE".draw(at: CGPoint(x: margin, y: 100), withAttributes: titleAttrs)
        "Diagnostic Report".draw(at: CGPoint(x: margin, y: 145), withAttributes: subtitleAttrs)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateStr = dateFormatter.string(from: result.date)
        dateStr.draw(at: CGPoint(x: margin, y: 175), withAttributes: subtitleAttrs)

        if !profile.firstName.isEmpty {
            let nameAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20, weight: .medium), .foregroundColor: darkColor]
            "Prepared for: \(profile.firstName)".draw(at: CGPoint(x: margin, y: 210), withAttributes: nameAttrs)
        }

        let scoreStr = "\(Int(result.overallScore))"
        let scoreSize = scoreStr.size(withAttributes: scoreAttrs)
        scoreStr.draw(at: CGPoint(x: (pageWidth - scoreSize.width) / 2, y: 320), withAttributes: scoreAttrs)

        let levelStr = result.level.rawValue.uppercased()
        let levelSize = levelStr.size(withAttributes: levelAttrs)
        levelStr.draw(at: CGPoint(x: (pageWidth - levelSize.width) / 2, y: 400), withAttributes: levelAttrs)

        let summary = AnalysisEngine.executiveSummary(result: result, profile: profile)
        let summaryAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.darkGray]
        let summaryRect = CGRect(x: margin, y: 480, width: pageWidth - margin * 2, height: 200)
        summary.draw(in: summaryRect, withAttributes: summaryAttrs)

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO (M5 Capital Partners LLC)".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func drawScoreBreakdown(context: UIGraphicsPDFRendererContext, result: AssessmentResult, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "Score Breakdown".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        var y: CGFloat = margin + 50

        for cs in result.categoryScores {
            let nameAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor.black]
            let scoreAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]

            cs.category.rawValue.draw(at: CGPoint(x: margin, y: y), withAttributes: nameAttrs)
            let scoreStr = "\(Int(cs.normalizedScore))"
            scoreStr.draw(at: CGPoint(x: pageWidth - margin - 40, y: y), withAttributes: scoreAttrs)

            let barY = y + 22
            let barHeight: CGFloat = 8
            let bgRect = CGRect(x: margin, y: barY, width: contentWidth, height: barHeight)
            UIColor.systemGray5.setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: 4).fill()

            let fillWidth = contentWidth * CGFloat(cs.normalizedScore / 100.0)
            let fillRect = CGRect(x: margin, y: barY, width: fillWidth, height: barHeight)
            UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1).setFill()
            UIBezierPath(roundedRect: fillRect, cornerRadius: 4).fill()

            y += 50
        }

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func drawCategoryAnalysis(context: UIGraphicsPDFRendererContext, result: AssessmentResult, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]
        let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.black]
        let catAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]
        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]

        for cs in result.categoryScores {
            context.beginPage()
            var y: CGFloat = margin

            let analysis = AnalysisEngine.categoryAnalysis(category: cs.category, score: cs.normalizedScore)

            cs.category.rawValue.draw(at: CGPoint(x: margin, y: y), withAttributes: catAttrs)
            y += 30

            "What This Means".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 20
            let meansRect = CGRect(x: margin, y: y, width: contentWidth, height: 60)
            analysis.whatThisMeans.draw(in: meansRect, withAttributes: bodyAttrs)
            y += 70

            "Pain Points".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 20
            for point in analysis.painPoints {
                let bulletText = "• \(point)"
                let bulletRect = CGRect(x: margin, y: y, width: contentWidth, height: 30)
                bulletText.draw(in: bulletRect, withAttributes: bodyAttrs)
                y += 25
            }
            y += 10

            "Opportunities".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 20
            for opp in analysis.opportunities {
                let bulletText = "• \(opp)"
                let bulletRect = CGRect(x: margin, y: y, width: contentWidth, height: 30)
                bulletText.draw(in: bulletRect, withAttributes: bodyAttrs)
                y += 25
            }
            y += 10

            "Potential Impact".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 20
            let impactRect = CGRect(x: margin, y: y, width: contentWidth, height: 40)
            analysis.potentialImpact.draw(in: impactRect, withAttributes: bodyAttrs)
            y += 50

            "Recommended Next Step".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 20
            let stepRect = CGRect(x: margin, y: y, width: contentWidth, height: 40)
            analysis.recommendedNextStep.draw(in: stepRect, withAttributes: bodyAttrs)

            "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
        }
    }

    private static func drawRecommendations(context: UIGraphicsPDFRendererContext, result: AssessmentResult, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "Top 5 Recommendations".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        let sorted = result.categoryScores.sorted { $0.normalizedScore < $1.normalizedScore }
        var y: CGFloat = margin + 50

        for (i, cs) in sorted.prefix(5).enumerated() {
            let analysis = AnalysisEngine.categoryAnalysis(category: cs.category, score: cs.normalizedScore)
            let numAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor.black]
            let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]

            "\(i + 1).".draw(at: CGPoint(x: margin, y: y), withAttributes: numAttrs)
            cs.category.rawValue.draw(at: CGPoint(x: margin + 20, y: y), withAttributes: titleAttrs)
            y += 22
            let stepRect = CGRect(x: margin + 20, y: y, width: contentWidth - 20, height: 40)
            analysis.recommendedNextStep.draw(in: stepRect, withAttributes: bodyAttrs)
            y += 55
        }

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func drawRoadmapOverview(context: UIGraphicsPDFRendererContext, roadmap: Roadmap, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "12-Week Roadmap Overview".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        var y: CGFloat = margin + 50
        let weekAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]
        let themeAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]
        let phaseAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: UIColor.gray]

        for week in roadmap.weeks {
            "Week \(week.weekNumber)".draw(at: CGPoint(x: margin, y: y), withAttributes: weekAttrs)
            week.theme.draw(at: CGPoint(x: margin + 70, y: y), withAttributes: themeAttrs)
            week.phase.draw(at: CGPoint(x: pageWidth - margin - 80, y: y), withAttributes: phaseAttrs)
            y += 22

            if y > pageHeight - 80 {
                context.beginPage()
                y = margin
            }
        }

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func drawIndustryBenchmarks(context: UIGraphicsPDFRendererContext, result: AssessmentResult, profile: UserProfile, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let tealColor = UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "Industry Benchmark".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        let subtitleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.gray]
        "How your scores compare to the average \(profile.industry.rawValue.lowercased()) professional".draw(at: CGPoint(x: margin, y: margin + 35), withAttributes: subtitleAttrs)

        let benchmarks = BenchmarkEngine.industryBenchmarks(result: result, industry: profile.industry, companySize: profile.companySize)
        var y: CGFloat = margin + 70

        let nameAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: UIColor.black]
        let valueAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: tealColor]
        let avgAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.gray]
        let deltaAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .bold)]

        for bm in benchmarks {
            bm.category.rawValue.draw(at: CGPoint(x: margin, y: y), withAttributes: nameAttrs)

            let scoreStr = "\(Int(bm.userScore))%"
            scoreStr.draw(at: CGPoint(x: margin + 200, y: y), withAttributes: valueAttrs)

            let avgStr = "Avg: \(Int(bm.industryAverage))%"
            avgStr.draw(at: CGPoint(x: margin + 260, y: y), withAttributes: avgAttrs)

            let deltaStr = bm.delta >= 0 ? "+\(Int(bm.delta))" : "\(Int(bm.delta))"
            let deltaColor = bm.delta >= 0 ? UIColor.systemGreen : UIColor.systemOrange
            let coloredDeltaAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .bold), .foregroundColor: deltaColor]
            deltaStr.draw(at: CGPoint(x: margin + 360, y: y), withAttributes: coloredDeltaAttrs)

            let barY = y + 22
            let barHeight: CGFloat = 6

            let bgRect = CGRect(x: margin, y: barY, width: contentWidth, height: barHeight)
            UIColor.systemGray5.setFill()
            UIBezierPath(roundedRect: bgRect, cornerRadius: 3).fill()

            let userWidth = contentWidth * CGFloat(bm.userScore / 100.0)
            let userRect = CGRect(x: margin, y: barY, width: userWidth, height: barHeight)
            tealColor.setFill()
            UIBezierPath(roundedRect: userRect, cornerRadius: 3).fill()

            let avgX = margin + contentWidth * CGFloat(bm.industryAverage / 100.0)
            let markerRect = CGRect(x: avgX - 1, y: barY - 2, width: 2, height: barHeight + 4)
            UIColor.gray.setFill()
            UIBezierPath(roundedRect: markerRect, cornerRadius: 1).fill()

            y += 48
        }

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func drawWhatsNextPage(context: UIGraphicsPDFRendererContext, result: AssessmentResult, profile: UserProfile, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let tealColor = UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)
        let darkColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)
        let orangeColor = UIColor(red: 236/255, green: 117/255, blue: 44/255, alpha: 1)

        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: tealColor]
        "What\u{2019}s Next?".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        let introAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.darkGray]
        let savings = BenchmarkEngine.estimatedAnnualSavings(industry: profile.industry, companySize: profile.companySize, currentScore: result.overallScore)
        let introText = "Your Pulse Score of \(Int(result.overallScore)) is a starting point, not a destination. Based on your industry and team size, closing your readiness gap could unlock $\(formatPDFNumber(savings.low))\u{2013}$\(formatPDFNumber(savings.high)) in annual productivity gains. Here\u{2019}s how to accelerate that transformation."
        let introRect = CGRect(x: margin, y: margin + 45, width: contentWidth, height: 80)
        introText.draw(in: introRect, withAttributes: introAttrs)

        var y: CGFloat = margin + 140

        let sectionHeaderAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: darkColor]
        let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: UIColor.darkGray]
        let accentAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: tealColor]
        let pricingAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: orangeColor]

        let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9, weight: .heavy), .foregroundColor: tealColor]
        "INCLUDED WITH BUSINESS".draw(at: CGPoint(x: margin, y: y), withAttributes: labelAttrs)
        y += 18

        "AI-Powered Diagnostic Suite".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttrs)
        y += 22
        let suiteText = "Your MVM Pulse Business subscription includes industry benchmarking, a personalized 12-week roadmap, AI coaching sessions, detailed category analysis, PDF diagnostic reports, and score history tracking \u{2014} all designed to close your readiness gap systematically."
        let suiteRect = CGRect(x: margin, y: y, width: contentWidth, height: 55)
        suiteText.draw(in: suiteRect, withAttributes: bodyAttrs)
        y += 65

        let divider1 = CGRect(x: margin, y: y, width: contentWidth, height: 0.5)
        tealColor.withAlphaComponent(0.2).setFill()
        UIBezierPath(rect: divider1).fill()
        y += 14

        let premLabel: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9, weight: .heavy), .foregroundColor: orangeColor]
        "PREMIUM ADVISORY SERVICES".draw(at: CGPoint(x: margin, y: y), withAttributes: premLabel)
        y += 18

        "1-on-1 Strategy Consultation".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttrs)
        y += 20
        let consultText = "Get personalized guidance from the M5CAIRO team. We review your full diagnostic, identify highest-leverage opportunities, and build a custom action plan for your \(profile.industry.rawValue.lowercased()) business."
        let consultRect = CGRect(x: margin, y: y, width: contentWidth, height: 45)
        consultText.draw(in: consultRect, withAttributes: bodyAttrs)
        y += 50
        "Contact for pricing".draw(at: CGPoint(x: margin, y: y), withAttributes: pricingAttrs)
        y += 22

        "Custom AI Integration Planning".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttrs)
        y += 20
        let aiText = "Your Technology & AI Readiness score reveals specific opportunities for automation and AI adoption. Our team specializes in practical integration strategies that boost productivity \u{2014} not reduce headcount \u{2014} delivering measurable ROI within 90 days."
        let aiRect = CGRect(x: margin, y: y, width: contentWidth, height: 45)
        aiText.draw(in: aiRect, withAttributes: bodyAttrs)
        y += 50
        "Contact for pricing".draw(at: CGPoint(x: margin, y: y), withAttributes: pricingAttrs)
        y += 22

        "Board-Ready Reports & Custom KPIs".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttrs)
        y += 20
        let boardText = "Investor-grade presentation decks and custom KPI tracking correlated with your Pulse Score, tailored for stakeholder meetings."
        let boardRect = CGRect(x: margin, y: y, width: contentWidth, height: 35)
        boardText.draw(in: boardRect, withAttributes: bodyAttrs)
        y += 40
        "Contact for pricing".draw(at: CGPoint(x: margin, y: y), withAttributes: pricingAttrs)
        y += 32

        let dividerRect = CGRect(x: margin, y: y, width: contentWidth, height: 1)
        tealColor.withAlphaComponent(0.3).setFill()
        UIBezierPath(rect: dividerRect).fill()
        y += 18

        "Ready to take action?".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttrs)
        y += 25

        "Visit:".draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAttrs)
        "https://m5cairo.com".draw(at: CGPoint(x: margin + 35, y: y), withAttributes: accentAttrs)
        y += 20

        "Email:".draw(at: CGPoint(x: margin, y: y), withAttributes: bodyAttrs)
        "contact@m5cairo.com".draw(at: CGPoint(x: margin + 40, y: y), withAttributes: accentAttrs)
        y += 25

        let closingText = "Mention your Pulse Score of \(Int(result.overallScore)) for a personalized consultation roadmap."
        let closingAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: tealColor]
        closingText.draw(at: CGPoint(x: margin, y: y), withAttributes: closingAttrs)

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO (M5 Capital Partners LLC)".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }

    private static func formatPDFNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private static func drawDisclaimerPage(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "Disclaimer".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]
        let disclaimer = "MVM Pulse is not a substitute for professional financial planning, business consulting, medical care, therapy, or any licensed professional service. All scores, insights, roadmaps, and recommendations are estimates based on your self-reported answers and general industry research. Every individual and business situation is different. M5 Capital Partners LLC (M5CAIRO) makes no guarantees regarding specific outcomes from using this app. Use at your own discretion.\n\nThis report is generated algorithmically from self-reported data and general benchmarks. It is intended as a diagnostic starting point, not a definitive evaluation. Consult qualified professionals for specific financial, legal, medical, or business advice.\n\n© M5 Capital Partners LLC. All rights reserved.\nContact: contact@m5cairo.com"

        let textRect = CGRect(x: margin, y: margin + 40, width: contentWidth, height: 400)
        disclaimer.draw(in: textRect, withAttributes: bodyAttrs)

        let ctaAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]
        "Continue your journey at mvmpulse.com".draw(at: CGPoint(x: margin, y: pageHeight - 100), withAttributes: ctaAttrs)

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }
}
