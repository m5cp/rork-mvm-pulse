import SwiftUI
import PDFKit

struct ExecutiveBriefingView: View {
    let storage: StorageService
    let ai: AIViewModel
    @State private var briefingText: String?
    @State private var isLoading: Bool = false
    @State private var showShareSheet: Bool = false
    @Environment(\.dismiss) private var dismiss

    private var completedTasks: Int {
        storage.roadmap.weeks.flatMap(\.tasks).filter(\.isCompleted).count
    }

    private var totalTasks: Int {
        storage.roadmap.weeks.flatMap(\.tasks).count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                trajectorySection
                if let text = briefingText {
                    aiAnalysisSection(text: text)
                } else if isLoading {
                    loadingSection
                }
                benchmarkSummarySection
                consultationCTA
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Executive Briefing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if briefingText != nil {
                    ShareLink(item: briefingPDFData, preview: SharePreview("Executive Briefing", image: Image(systemName: "doc.fill"))) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .onAppear { generateBriefing() }
    }

    private var briefingPDFData: Data {
        ExecutiveBriefingPDFService.generate(
            results: storage.assessmentResults,
            profile: storage.userProfile,
            roadmapProgress: storage.roadmap.overallProgress,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            briefingText: briefingText ?? ""
        )
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(PulseTheme.primaryTeal)

            Text("Quarterly Executive Briefing")
                .font(.title3.bold())

            if let latest = storage.latestResult {
                Text("Prepared for \(storage.userProfile.firstName.isEmpty ? "User" : storage.userProfile.firstName) \u{00B7} \(Date(), style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    metricPill(label: "Score", value: "\(Int(latest.overallScore))", color: PulseTheme.scoreColor(for: latest.overallScore))
                    metricPill(label: "Level", value: latest.level.rawValue, color: PulseTheme.scoreColor(for: latest.level))
                    metricPill(label: "Streak", value: "\(storage.streakData.currentStreak)d", color: .orange)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private func metricPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var trajectorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Score Trajectory")
                    .font(.subheadline.bold())
            }

            if storage.assessmentResults.count >= 2 {
                HStack(spacing: 8) {
                    ForEach(Array(storage.assessmentResults.enumerated()), id: \.element.id) { index, result in
                        VStack(spacing: 4) {
                            Text("\(Int(result.overallScore))")
                                .font(.headline.bold())
                                .foregroundStyle(PulseTheme.scoreColor(for: result.overallScore))
                            Text(result.date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        if index < storage.assessmentResults.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.quaternary)
                        }
                    }
                }
            } else {
                Text("Complete additional assessments to see trajectory data.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                progressMetric(label: "Roadmap", value: "\(Int(storage.roadmap.overallProgress * 100))%")
                progressMetric(label: "Tasks Done", value: "\(completedTasks)/\(totalTasks)")
                progressMetric(label: "Assessments", value: "\(storage.assessmentResults.count)")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func progressMetric(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func aiAnalysisSection(text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("AI Executive Analysis")
                    .font(.subheadline.bold())
            }

            Text(text)
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

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Generating executive briefing...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var benchmarkSummarySection: some View {
        Group {
            if let result = storage.latestResult {
                let benchmarks = BenchmarkEngine.industryBenchmarks(
                    result: result,
                    industry: storage.userProfile.industry,
                    companySize: storage.userProfile.companySize
                )
                let above = benchmarks.filter { $0.delta > 0 }
                let below = benchmarks.filter { $0.delta <= 0 }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(PulseTheme.primaryTeal)
                        Text("Industry Position")
                            .font(.subheadline.bold())
                    }

                    if !above.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ABOVE INDUSTRY AVERAGE")
                                .font(.caption2.bold())
                                .foregroundStyle(.green)
                                .tracking(0.5)

                            ForEach(above, id: \.category) { bm in
                                HStack {
                                    Text(bm.category.rawValue)
                                        .font(.caption)
                                    Spacer()
                                    Text("+\(Int(bm.delta)) pts")
                                        .font(.caption.bold())
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }

                    if !below.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("BELOW INDUSTRY AVERAGE")
                                .font(.caption2.bold())
                                .foregroundStyle(.orange)
                                .tracking(0.5)

                            ForEach(below, id: \.category) { bm in
                                HStack {
                                    Text(bm.category.rawValue)
                                        .font(.caption)
                                    Spacer()
                                    Text("\(Int(bm.delta)) pts")
                                        .font(.caption.bold())
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 16))
            }
        }
    }

    private var consultationCTA: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.2.fill")
                .font(.title2)
                .foregroundStyle(PulseTheme.primaryTeal)

            Text("Want Expert Guidance?")
                .font(.headline)

            Text("The M5CAIRO team can help you translate these insights into a tailored strategy for your business.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                if let url = URL(string: "https://m5cairo.com") {
                    Link(destination: url) {
                        Text("Visit m5cairo.com")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(PulseTheme.primaryTeal)
                }

                if let mailURL = URL(string: "mailto:contact@m5cairo.com") {
                    Link(destination: mailURL) {
                        Text("Email Us")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .tint(PulseTheme.primaryTeal)
                }
            }
        }
        .padding(20)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PulseTheme.primaryTeal.opacity(0.15), lineWidth: 1)
        )
    }

    private func generateBriefing() {
        guard !isLoading, briefingText == nil else { return }
        isLoading = true
        Task {
            let text = await ai.groq.generateExecutiveBriefing(
                results: storage.assessmentResults,
                profile: storage.userProfile,
                roadmapProgress: storage.roadmap.overallProgress,
                completedTasks: completedTasks,
                totalTasks: totalTasks,
                streakDays: storage.streakData.currentStreak
            )
            briefingText = text
            isLoading = false
        }
    }
}

struct ExecutiveBriefingPDFService {
    static func generate(results: [AssessmentResult], profile: UserProfile, roadmapProgress: Double, completedTasks: Int, totalTasks: Int, briefingText: String) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2
        let tealColor = UIColor(red: 9/255, green: 119/255, blue: 112/255, alpha: 1)
        let darkColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()

            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: darkColor]
            "QUARTERLY EXECUTIVE BRIEFING".draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttrs)

            let subtitleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.gray]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateStr = dateFormatter.string(from: Date())
            "Prepared for \(profile.firstName.isEmpty ? "User" : profile.firstName) \u{00B7} \(dateStr)".draw(at: CGPoint(x: margin, y: margin + 40), withAttributes: subtitleAttrs)

            let brandAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: tealColor]
            "MVM Pulse by M5CAIRO".draw(at: CGPoint(x: margin, y: margin + 60), withAttributes: brandAttrs)

            var y: CGFloat = margin + 100

            let sectionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: darkColor]
            let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: UIColor.darkGray]
            let metricAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: tealColor]

            "KEY METRICS".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 25

            if let latest = results.last {
                "Pulse Score: \(Int(latest.overallScore))/100 (\(latest.level.rawValue))".draw(at: CGPoint(x: margin, y: y), withAttributes: metricAttrs)
                y += 20
            }

            "Roadmap Progress: \(Int(roadmapProgress * 100))% (\(completedTasks)/\(totalTasks) tasks)".draw(at: CGPoint(x: margin, y: y), withAttributes: metricAttrs)
            y += 20

            "Total Assessments: \(results.count)".draw(at: CGPoint(x: margin, y: y), withAttributes: metricAttrs)
            y += 35

            "EXECUTIVE ANALYSIS".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 25

            let briefingRect = CGRect(x: margin, y: y, width: contentWidth, height: 200)
            briefingText.draw(in: briefingRect, withAttributes: bodyAttrs)
            y += 220

            "NEXT STEPS".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionAttrs)
            y += 25

            let ctaText = "For a personalized strategy consultation based on this briefing, contact the M5CAIRO team:\n\nWebsite: https://m5cairo.com\nEmail: contact@m5cairo.com"
            let ctaRect = CGRect(x: margin, y: y, width: contentWidth, height: 100)
            ctaText.draw(in: ctaRect, withAttributes: bodyAttrs)

            let footerAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.lightGray]
            "MVM Pulse by M5CAIRO (M5 Capital Partners LLC) \u{00B7} Confidential".draw(at: CGPoint(x: margin, y: pageHeight - 50), withAttributes: footerAttrs)
        }
    }
}
