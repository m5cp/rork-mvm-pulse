import SwiftUI

struct ScoreCalculatingView: View {
    let onFinished: () -> Void

    @State private var phase: CalcPhase = .initial
    @State private var activeCategory: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum CalcPhase {
        case initial, scanning, done
    }

    private let categories = AssessmentCategory.allCases

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                ZStack {
                    ForEach(0..<categories.count, id: \.self) { i in
                        Circle()
                            .fill(PulseTheme.categoryColor(for: categories[i]).opacity(activeCategory == i ? 0.25 : 0.06))
                            .frame(width: 120, height: 120)
                            .offset(
                                x: cos(Double(i) * .pi / 4) * 50,
                                y: sin(Double(i) * .pi / 4) * 50
                            )
                            .blur(radius: 20)
                            .scaleEffect(activeCategory == i ? 1.2 : 0.8)
                    }

                    Circle()
                        .stroke(PulseTheme.primaryTeal.opacity(0.2), lineWidth: 6)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: phase == .scanning ? Double(activeCategory + 1) / Double(categories.count) : 0)
                        .stroke(PulseTheme.primaryTeal, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(PulseTheme.primaryTeal)
                        .symbolEffect(.pulse, options: .repeating, isActive: phase == .scanning)
                }

                VStack(spacing: 12) {
                    Text("Analyzing your responses")
                        .font(.title3.bold())

                    if phase == .scanning, activeCategory < categories.count {
                        Text(categories[activeCategory].rawValue)
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.categoryColor(for: categories[activeCategory]))
                            .contentTransition(.numericText())
                            .animation(.snappy, value: activeCategory)
                    } else {
                        Text("Preparing your results...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onFinished()
                }
                return
            }
            startAnimation()
        }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            phase = .scanning
        }

        for i in 0..<categories.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.25) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    activeCategory = i
                }
            }
        }

        let totalTime = Double(categories.count) * 0.25 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            withAnimation(.easeOut(duration: 0.2)) {
                phase = .done
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onFinished()
            }
        }
    }
}
