import SwiftUI

struct AssessmentView: View {
    let questions: [AssessmentQuestion]
    let mode: AssessmentMode
    let existingResponses: [AssessmentResponse]
    let onComplete: ([AssessmentResponse]) -> Void

    @State private var currentIndex: Int = 0
    @State private var responses: [AssessmentResponse] = []
    @State private var selectedOptionId: String?
    @State private var isTransitioning: Bool = false
    @State private var selectionHaptic: Int = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentQuestion: AssessmentQuestion {
        questions[currentIndex]
    }

    private var progress: Double {
        Double(currentIndex) / Double(questions.count)
    }

    private var catColor: Color {
        PulseTheme.categoryColor(for: currentQuestion.category)
    }

    private var categoryQuestionsInFlow: [AssessmentQuestion] {
        questions.filter { $0.category == currentQuestion.category }
    }

    private var categoryQuestionIndex: Int {
        (categoryQuestionsInFlow.firstIndex(where: { $0.id == currentQuestion.id }) ?? 0) + 1
    }

    private var categoryQuestionTotal: Int {
        categoryQuestionsInFlow.count
    }

    private var headerSubtitle: String {
        switch mode {
        case .quick: return "Quick Pulse \u{00b7} \(currentIndex + 1) of \(questions.count)"
        case .deepDive: return "Deep Dive \u{00b7} \(currentIndex + 1) of \(questions.count)"
        case .full: return "\(currentIndex + 1) of \(questions.count)"
        }
    }

    private var estimatedMinutes: Int {
        let remaining = questions.count - currentIndex
        return max(1, Int(ceil(Double(remaining) * 8.0 / 60.0)))
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                ProgressView(value: progress)
                    .tint(catColor)
                    .animation(.smooth, value: progress)

                HStack {
                    Label(currentQuestion.category.rawValue, systemImage: currentQuestion.category.icon)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(catColor)

                    Spacer()

                    Text(headerSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if mode == .quick && currentIndex == 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("~\(estimatedMinutes) min \u{00b7} 24 questions")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.orange.opacity(0.08))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 24) {
                    Text(currentQuestion.text)
                        .font(.title3.bold())
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                        .id(currentQuestion.id)

                    VStack(spacing: 10) {
                        ForEach(currentQuestion.options) { option in
                            Button {
                                selectOption(option)
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .strokeBorder(selectedOptionId == option.id ? catColor : Color(.separator), lineWidth: selectedOptionId == option.id ? 6 : 2)
                                        .frame(width: 24, height: 24)
                                        .padding(.top, 2)

                                    Text(option.text)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(16)
                                .background(
                                    selectedOptionId == option.id
                                        ? catColor.opacity(0.08)
                                        : Color(.secondarySystemGroupedBackground)
                                )
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(
                                            selectedOptionId == option.id ? catColor : .clear,
                                            lineWidth: 1.5
                                        )
                                )
                                .scaleEffect(selectedOptionId == option.id ? 0.98 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: selectedOptionId)
                            }
                            .buttonStyle(.plain)
                            .disabled(isTransitioning)
                            .accessibilityLabel("\(option.text), score \(option.score) of 5")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .sensoryFeedback(.selection, trigger: selectionHaptic)

            if currentIndex > 0 {
                HStack {
                    Button {
                        goBack()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    Text("\(categoryQuestionIndex) of \(categoryQuestionTotal) in \(currentQuestion.category.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            responses = existingResponses
            selectedOptionId = existingResponses.first(where: { $0.questionId == questions.first?.id })?.selectedOptionId
        }
    }

    private func selectOption(_ option: AnswerOption) {
        guard !isTransitioning else { return }
        selectedOptionId = option.id
        isTransitioning = true
        selectionHaptic += 1

        let response = AssessmentResponse(
            questionId: currentQuestion.id,
            selectedOptionId: option.id,
            score: option.score
        )

        if let existingIdx = responses.firstIndex(where: { $0.questionId == currentQuestion.id }) {
            responses[existingIdx] = response
        } else {
            responses.append(response)
        }

        let delay: Duration = reduceMotion ? .milliseconds(200) : .milliseconds(400)

        Task {
            try? await Task.sleep(for: delay)
            if currentIndex < questions.count - 1 {
                withAnimation(reduceMotion ? .none : .smooth(duration: 0.3)) {
                    currentIndex += 1
                    selectedOptionId = responses.first(where: { $0.questionId == questions[currentIndex].id })?.selectedOptionId
                }
            } else {
                onComplete(responses)
            }
            isTransitioning = false
        }
    }

    private func goBack() {
        guard currentIndex > 0 else { return }
        withAnimation(reduceMotion ? .none : .smooth(duration: 0.3)) {
            currentIndex -= 1
            selectedOptionId = responses.first(where: { $0.questionId == questions[currentIndex].id })?.selectedOptionId
        }
    }
}
