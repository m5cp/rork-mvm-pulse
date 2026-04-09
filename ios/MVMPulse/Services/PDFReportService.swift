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
            drawCategoryAnalysis(context: context, result: result, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawRecommendations(context: context, result: result, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
            drawRoadmapOverview(context: context, roadmap: roadmap, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin, contentWidth: contentWidth)
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

    private static func drawDisclaimerPage(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat, contentWidth: CGFloat) {
        context.beginPage()
        let headerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)]
        "Disclaimer".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerAttrs)

        let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]
        let disclaimer = "MVM Pulse is not a substitute for professional financial planning, business consulting, medical care, therapy, or any licensed professional service. All scores, insights, roadmaps, and recommendations are estimates based on your self-reported answers and general industry research. Every individual and business situation is different. M5 Capital Partners LLC (M5CAIRO) makes no guarantees regarding specific outcomes from using this app. Use at your own discretion.\n\nThis report is generated algorithmically from self-reported data and general benchmarks. It is intended as a diagnostic starting point, not a definitive evaluation. Consult qualified professionals for specific financial, legal, medical, or business advice.\n\n© M5 Capital Partners LLC. All rights reserved.\nContact: m5cp@proton.me"

        let textRect = CGRect(x: margin, y: margin + 40, width: contentWidth, height: 400)
        disclaimer.draw(in: textRect, withAttributes: bodyAttrs)

        let ctaAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)]
        "Continue your journey at mvmpulse.com".draw(at: CGPoint(x: margin, y: pageHeight - 100), withAttributes: ctaAttrs)

        let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
        "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
    }
}
