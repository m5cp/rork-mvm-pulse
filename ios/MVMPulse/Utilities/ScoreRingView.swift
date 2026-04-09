import SwiftUI

struct ScoreRingView: View {
    let score: Double
    let size: CGFloat
    let lineWidth: CGFloat
    var animated: Bool = true
    var showGlow: Bool = false

    @State private var animatedProgress: Double = 0
    @State private var displayedScore: Int = 0
    @State private var glowPulse: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progress: Double { score / 100.0 }
    private var color: Color { PulseTheme.scoreColor(for: score) }

    var body: some View {
        ZStack {
            if showGlow {
                Circle()
                    .fill(color.opacity(glowPulse ? 0.12 : 0.04))
                    .frame(width: size + 40, height: size + 40)
                    .blur(radius: 20)
            }

            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animated ? animatedProgress : progress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.5), color, color],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * (animated ? animatedProgress : progress))
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if animated && animatedProgress > 0 {
                Circle()
                    .fill(color)
                    .frame(width: lineWidth * 0.6, height: lineWidth * 0.6)
                    .blur(radius: 4)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * animatedProgress - 90))
                    .opacity(animatedProgress > 0.05 ? 0.8 : 0)
            }

            VStack(spacing: 2) {
                Text("\(animated ? displayedScore : Int(score))")
                    .font(.system(size: size * 0.28, weight: .heavy))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

                Text(ScoreLevel.from(score: score).rawValue.uppercased())
                    .font(.system(size: size * 0.07, weight: .bold))
                    .foregroundStyle(color)
                    .tracking(1.5)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pulse Score \(Int(score)), \(ScoreLevel.from(score: score).rawValue)")
        .onAppear {
            guard animated else { return }
            if reduceMotion {
                animatedProgress = progress
                displayedScore = Int(score)
                return
            }
            animateIn()
        }
    }

    private func animateIn() {
        withAnimation(.spring(response: 1.4, dampingFraction: 0.82).delay(0.2)) {
            animatedProgress = progress
        }

        countUpScore()

        if showGlow {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.6)) {
                glowPulse = true
            }
        }
    }

    private func countUpScore() {
        let target = Int(score)
        let totalDuration: Double = 1.2
        let steps = target
        guard steps > 0 else { return }
        let interval = totalDuration / Double(steps)

        for i in 1...steps {
            let delay = 0.2 + Double(i) * interval
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.none) {
                    displayedScore = i
                }
            }
        }
    }
}

struct MiniProgressBar: View {
    let value: Double
    let color: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.15))

                Capsule()
                    .fill(color)
                    .frame(width: max(0, geo.size.width * CGFloat(min(value / 100.0, 1.0))))
            }
        }
        .frame(height: height)
    }
}
