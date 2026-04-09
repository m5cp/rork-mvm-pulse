import SwiftUI

struct LaunchAnimationView: View {
    let onFinished: () -> Void

    @State private var phase: LaunchPhase = .void
    @State private var particles: [LaunchParticle] = []
    @State private var timelineActive: Bool = true
    @State private var startTime: Date = .now

    @State private var meshMorph: Bool = false
    @State private var meshGlow: Double = 0
    @State private var ringProgress: Double = 0
    @State private var ringScale: Double = 0.3
    @State private var ringOpacity: Double = 0
    @State private var innerRingProgress: Double = 0
    @State private var scoreOpacity: Double = 0
    @State private var scoreScale: Double = 2.0
    @State private var displayNumber: Int = 0
    @State private var wordReveal: [Bool] = [false, false, false]
    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: Double = 15
    @State private var logoScale: Double = 0.5
    @State private var logoOpacity: Double = 0
    @State private var flashOpacity: Double = 0
    @State private var contentOpacity: Double = 1
    @State private var pulseGlowScale: Double = 1.0
    @State private var pulseGlowOpacity: Double = 0
    @State private var particleBurst: Bool = false
    @State private var vignetteDarken: Double = 0.6

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let particleCount = 120

    enum LaunchPhase {
        case void, particlesEmerge, converge, ringForm, scoreReveal, brandReveal, exit
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            meshBackground
            particleField
            vignetteOverlay

            VStack(spacing: 0) {
                Spacer()
                logoMark
                    .padding(.bottom, 16)
                wordStack
                    .padding(.bottom, 32)
                scoreRing
                tagline
                    .padding(.top, 24)
                Spacer()
                Spacer()
            }
            .opacity(contentOpacity)

            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)
        }
        .onAppear {
            if reduceMotion {
                onFinished()
                return
            }
            generateParticles()
            runCinematicSequence()
        }
    }

    private var meshBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: meshMorph ? [
                [0.0, 0.0], [0.5, -0.15], [1.0, 0.0],
                [-0.15, 0.55], [0.55, 0.45], [1.15, 0.5],
                [0.0, 1.0], [0.45, 1.15], [1.0, 1.0]
            ] : [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .black, Color(red: 0.02, green: 0.06, blue: 0.1), .black,
                Color(red: 0.01, green: 0.08, blue: 0.08), PulseTheme.primaryTeal.opacity(meshGlow * 0.5), Color(red: 0.0, green: 0.05, blue: 0.12).opacity(meshGlow * 0.3),
                .black, Color(red: 0.0, green: 0.15, blue: 0.2).opacity(meshGlow * 0.25), .black
            ]
        )
        .ignoresSafeArea()
    }

    private var particleField: some View {
        TimelineView(.animation(paused: !timelineActive)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.48)
                for particle in particles {
                    let age = elapsed - particle.delay
                    guard age > 0 else { continue }

                    let convergeT = particleBurst ? min(age / 1.8, 1.0) : 0.0
                    let eased = convergeT * convergeT * (3 - 2 * convergeT)

                    let driftX = particle.startX + sin(age * particle.speed + particle.phase) * particle.amplitude * 0.3
                    let driftY = particle.startY + cos(age * particle.speed * 0.7 + particle.phase) * particle.amplitude * 0.2 - CGFloat(age) * particle.rise

                    let currentX = driftX + (center.x - driftX) * eased
                    let currentY = driftY + (center.y - driftY) * eased

                    let fadeIn = min(age / 0.6, 1.0)
                    let convergedFade = convergeT > 0.85 ? max(0, 1 - (convergeT - 0.85) / 0.15) : 1.0
                    let alpha = fadeIn * particle.opacity * convergedFade

                    let sz = particle.size * (1 + sin(age * 2 + particle.phase) * 0.3) * (1 - eased * 0.5)

                    let color: Color
                    switch particle.colorType {
                    case 0: color = PulseTheme.primaryTeal
                    case 1: color = Color(red: 0.2, green: 0.8, blue: 0.9)
                    case 2: color = Color(red: 0.4, green: 0.95, blue: 0.85)
                    default: color = .white
                    }

                    let rect = CGRect(x: currentX - sz / 2, y: currentY - sz / 2, width: sz, height: sz)
                    context.opacity = alpha
                    context.fill(Circle().path(in: rect), with: .color(color))

                    if particle.hasGlow {
                        let glowRect = CGRect(x: currentX - sz * 2, y: currentY - sz * 2, width: sz * 4, height: sz * 4)
                        context.opacity = alpha * 0.15
                        context.fill(Circle().path(in: glowRect), with: .color(color))
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var vignetteOverlay: some View {
        RadialGradient(
            colors: [.clear, .black.opacity(vignetteDarken)],
            center: .center,
            startRadius: 100,
            endRadius: 450
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var logoMark: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PulseTheme.primaryTeal.opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(pulseGlowScale)
                .opacity(pulseGlowOpacity)

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [PulseTheme.primaryTeal, Color(red: 0.2, green: 0.85, blue: 0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }

    private var wordStack: some View {
        VStack(spacing: 4) {
            wordView("DIAGNOSE", index: 0, color: .white)
            wordView("UNDERSTAND", index: 1, color: .white)
            wordView("EXECUTE", index: 2, color: PulseTheme.primaryTeal)
        }
    }

    private func wordView(_ text: String, index: Int, color: Color) -> some View {
        let revealed = index < wordReveal.count ? wordReveal[index] : false
        return Text(text)
            .font(.system(size: 38, weight: .black, design: .default))
            .tracking(6)
            .foregroundStyle(color)
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 30)
            .blur(radius: revealed ? 0 : 8)
            .scaleEffect(revealed ? 1 : 0.85)
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 4)
                .frame(width: 140, height: 140)
                .opacity(ringOpacity)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            PulseTheme.primaryTeal,
                            Color(red: 0.2, green: 0.85, blue: 0.8),
                            PulseTheme.primaryTeal
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .opacity(ringOpacity)

            Circle()
                .trim(from: 0, to: innerRingProgress)
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
                .opacity(ringOpacity)

            Text("\(displayNumber)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .opacity(scoreOpacity)
                .scaleEffect(scoreScale)
                .contentTransition(.numericText(countsDown: false))
        }
        .scaleEffect(ringScale)
        .frame(height: 180)
    }

    private var tagline: some View {
        Text("Know your number. Own your trajectory.")
            .font(.subheadline.weight(.medium))
            .tracking(1.5)
            .foregroundStyle(.white.opacity(0.5))
            .opacity(taglineOpacity)
            .offset(y: taglineOffset)
    }

    private func generateParticles() {
        let screenW: CGFloat = UIScreen.main.bounds.width
        let screenH: CGFloat = UIScreen.main.bounds.height
        particles = (0..<particleCount).map { _ in
            LaunchParticle(
                startX: CGFloat.random(in: -20...screenW + 20),
                startY: CGFloat.random(in: -20...screenH + 20),
                size: CGFloat.random(in: 1.5...5),
                opacity: Double.random(in: 0.15...0.7),
                speed: Double.random(in: 0.3...1.5),
                phase: Double.random(in: 0...(.pi * 2)),
                amplitude: CGFloat.random(in: 15...60),
                rise: CGFloat.random(in: 3...15),
                delay: Double.random(in: 0...1.2),
                colorType: Int.random(in: 0...3),
                hasGlow: Bool.random()
            )
        }
    }

    private func runCinematicSequence() {
        startTime = .now

        withAnimation(.easeOut(duration: 2.0)) {
            meshGlow = 0.4
        }
        withAnimation(.easeInOut(duration: 3.0).delay(0.3)) {
            meshMorph = true
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.6)) {
            logoOpacity = 1
            logoScale = 1.0
        }

        withAnimation(.easeInOut(duration: 1.5).delay(0.8)) {
            pulseGlowOpacity = 0.6
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.8)) {
            pulseGlowScale = 1.4
        }

        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(1.0)) {
            wordReveal[0] = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(1.25)) {
            wordReveal[1] = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(1.5)) {
            wordReveal[2] = true
        }

        withAnimation(.easeOut(duration: 0.8).delay(1.5)) {
            meshGlow = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            particleBurst = true
        }

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(2.0)) {
            ringOpacity = 1
            ringScale = 1.0
        }
        withAnimation(.easeInOut(duration: 1.2).delay(2.1)) {
            ringProgress = 0.88
            innerRingProgress = 1.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(2.3)) {
            scoreOpacity = 1
            scoreScale = 1.0
        }

        animateCounter(to: 88, startDelay: 2.35, duration: 0.7)

        withAnimation(.easeOut(duration: 0.5).delay(2.8)) {
            vignetteDarken = 0.3
        }

        withAnimation(.easeOut(duration: 0.6).delay(3.0)) {
            taglineOpacity = 1
            taglineOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeIn(duration: 0.15)) {
                flashOpacity = 0.6
            }
            withAnimation(.easeIn(duration: 0.2)) {
                contentOpacity = 0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.15)) {
                flashOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                timelineActive = false
                onFinished()
            }
        }
    }

    private func animateCounter(to end: Int, startDelay: Double, duration: Double) {
        let steps = end
        let interval = duration / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + startDelay + Double(i) * interval) {
                displayNumber = i
            }
        }
    }
}

private struct LaunchParticle {
    let startX: CGFloat
    let startY: CGFloat
    let size: CGFloat
    let opacity: Double
    let speed: Double
    let phase: Double
    let amplitude: CGFloat
    let rise: CGFloat
    let delay: Double
    let colorType: Int
    let hasGlow: Bool
}
