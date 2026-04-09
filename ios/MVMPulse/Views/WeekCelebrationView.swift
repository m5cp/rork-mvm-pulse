import SwiftUI

struct WeekCelebrationView: View {
    let weekNumber: Int
    let onContinue: () -> Void
    @State private var appeared: Bool = false
    @State private var ringScale: CGFloat = 0.3
    @State private var checkScale: CGFloat = 0
    @State private var confettiPhase: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if appeared && !reduceMotion {
                ConfettiLayer(phase: confettiPhase)
                    .allowsHitTesting(false)
            }

            VStack(spacing: 36) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .scaleEffect(ringScale)

                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .scaleEffect(ringScale)

                    ZStack {
                        Circle()
                            .fill(PulseTheme.primaryTeal)
                            .frame(width: 100, height: 100)

                        Image(systemName: "checkmark")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(checkScale)
                    }
                }

                VStack(spacing: 12) {
                    Text("Week \(weekNumber) Complete")
                        .font(.title.bold())
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Text(completionMessage)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(appeared ? 1 : 0)
            }
        }
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            if reduceMotion {
                appeared = true
                ringScale = 1
                checkScale = 1
                return
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                ringScale = 1
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.3)) {
                checkScale = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                appeared = true
            }
            confettiPhase += 1
        }
    }

    private var completionMessage: String {
        switch weekNumber {
        case 1: return "Diagnostic phase done. You now have a clear picture of where you stand."
        case 2...4: return "Foundation phase progressing. The building blocks are locking into place."
        case 5...8: return "Implementation is where real change happens. You're in the thick of it."
        case 9...12: return "Optimization phase. You're refining what's already working."
        default: return "Great work. Keep the momentum going."
        }
    }
}

struct ConfettiLayer: View {
    let phase: Int
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x * size.width - 4,
                    y: particle.y * size.height - 4,
                    width: 8, height: 8
                )
                context.fill(
                    RoundedRectangle(cornerRadius: 2).path(in: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
            }
        }
        .ignoresSafeArea()
        .onChange(of: phase) { _, _ in
            spawnParticles()
        }
        .onAppear {
            spawnParticles()
        }
    }

    private func spawnParticles() {
        let colors: [Color] = [PulseTheme.primaryTeal, .orange, .green, .blue, .purple, .pink]
        particles = (0..<40).map { _ in
            ConfettiParticle(
                x: Double.random(in: 0.1...0.9),
                y: Double.random(in: -0.1...0.0),
                color: colors.randomElement() ?? .blue,
                opacity: 1.0
            )
        }
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.0...2.0)
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                particles[i].y = Double.random(in: 0.7...1.2)
                particles[i].x += Double.random(in: -0.15...0.15)
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: Double
    var y: Double
    let color: Color
    var opacity: Double
}
