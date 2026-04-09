import SwiftUI

struct LaunchAnimationView: View {
    let onFinished: () -> Void

    @State private var particles: [LaunchParticle] = []
    @State private var timelineActive: Bool = true
    @State private var startTime: Date = .now

    @State private var meshMorph: Bool = false
    @State private var meshGlow: Double = 0
    @State private var meshPhase: Int = 0

    @State private var heartbeatScale: Double = 0.01
    @State private var heartbeatOpacity: Double = 0
    @State private var heartbeatGlowRadius: Double = 0
    @State private var heartbeatRingScale: Double = 0.5
    @State private var heartbeatRingOpacity: Double = 0
    @State private var secondPulseScale: Double = 0.5
    @State private var secondPulseOpacity: Double = 0

    @State private var logoScale: Double = 0.01
    @State private var logoOpacity: Double = 0
    @State private var logoRotation: Double = -15

    @State private var wordReveal: [Bool] = [false, false, false]
    @State private var wordGlow: [Double] = [0, 0, 0]

    @State private var ringProgress: Double = 0
    @State private var ringScale: Double = 0.2
    @State private var ringOpacity: Double = 0
    @State private var innerRingProgress: Double = 0
    @State private var outerRingRotation: Double = 0
    @State private var scoreOpacity: Double = 0
    @State private var scoreScale: Double = 3.0
    @State private var displayNumber: Int = 0

    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: Double = 20
    @State private var taglineBlur: Double = 6

    @State private var flashOpacity: Double = 0
    @State private var contentOpacity: Double = 1
    @State private var particleBurst: Bool = false
    @State private var vignetteDarken: Double = 0.85
    @State private var shockwaveScale: Double = 0.01
    @State private var shockwaveOpacity: Double = 0

    @State private var exitProgress: Double = 0
    @State private var exitBlur: Double = 0
    @State private var exitScale: Double = 1.0

    @State private var horizontalLineProgress: Double = 0
    @State private var horizontalLineOpacity: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let particleCount = 160

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            meshBackground
            particleField
            vignetteOverlay

            shockwaveRing

            VStack(spacing: 0) {
                Spacer()

                logoMark
                    .padding(.bottom, 8)

                decorativeLine
                    .padding(.bottom, 20)

                wordStack
                    .padding(.bottom, 40)

                scoreRing

                tagline
                    .padding(.top, 28)

                Spacer()
            }
            .opacity(contentOpacity)
            .scaleEffect(exitScale)
            .blur(radius: exitBlur)

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
                [0.0, 0.0], [0.5, -0.2], [1.0, 0.0],
                [-0.2, 0.55], [0.55, 0.42], [1.2, 0.5],
                [0.0, 1.0], [0.42, 1.2], [1.0, 1.0]
            ] : [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: meshColors
        )
        .ignoresSafeArea()
    }

    private var meshColors: [Color] {
        let g = meshGlow
        let teal = PulseTheme.primaryTeal
        return [
            .black,
            Color(red: 0.01, green: 0.04 * g, blue: 0.08 * g),
            .black,
            Color(red: 0.0, green: 0.06 * g, blue: 0.06 * g),
            teal.opacity(g * 0.6),
            Color(red: 0.0, green: 0.03 * g, blue: 0.1 * g),
            .black,
            Color(red: 0.0, green: 0.12 * g, blue: 0.18 * g),
            .black
        ]
    }

    private var particleField: some View {
        TimelineView(.animation(paused: !timelineActive)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.42)
                for particle in particles {
                    let age = elapsed - particle.delay
                    guard age > 0 else { continue }

                    let convergeT = particleBurst ? min((age - 2.5) / 2.5, 1.0) : 0.0
                    let clampedConverge = max(convergeT, 0)
                    let eased = clampedConverge * clampedConverge * (3 - 2 * clampedConverge)

                    let breathe = sin(age * 0.5 + particle.phase) * 0.15 + 1.0
                    let driftX = particle.startX + sin(age * particle.speed * 0.6 + particle.phase) * particle.amplitude * 0.4 * breathe
                    let driftY = particle.startY + cos(age * particle.speed * 0.4 + particle.phase) * particle.amplitude * 0.25 - CGFloat(age) * particle.rise * 0.6

                    let currentX = driftX + (center.x - driftX) * eased
                    let currentY = driftY + (center.y - driftY) * eased

                    let fadeIn = min(age / 1.0, 1.0)
                    let convergedFade = clampedConverge > 0.8 ? max(0, 1 - (clampedConverge - 0.8) / 0.2) : 1.0
                    let alpha = fadeIn * particle.opacity * convergedFade

                    let twinkle = sin(age * 3 + particle.phase * 2) * 0.3 + 0.7
                    let sz = particle.size * (1 + sin(age * 1.5 + particle.phase) * 0.25) * twinkle * (1 - eased * 0.6)

                    let color: Color
                    switch particle.colorType {
                    case 0: color = PulseTheme.primaryTeal
                    case 1: color = Color(red: 0.15, green: 0.75, blue: 0.85)
                    case 2: color = Color(red: 0.35, green: 0.95, blue: 0.8)
                    default: color = Color(red: 0.7, green: 0.95, blue: 0.95)
                    }

                    let rect = CGRect(x: currentX - sz / 2, y: currentY - sz / 2, width: sz, height: sz)
                    context.opacity = alpha
                    context.fill(Circle().path(in: rect), with: .color(color))

                    if particle.hasGlow {
                        let glowRect = CGRect(x: currentX - sz * 3, y: currentY - sz * 3, width: sz * 6, height: sz * 6)
                        context.opacity = alpha * 0.1
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
            startRadius: 80,
            endRadius: 500
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var shockwaveRing: some View {
        Circle()
            .stroke(
                PulseTheme.primaryTeal.opacity(0.4),
                lineWidth: 2
            )
            .frame(width: 200, height: 200)
            .scaleEffect(shockwaveScale)
            .opacity(shockwaveOpacity)
            .allowsHitTesting(false)
    }

    private var logoMark: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [PulseTheme.primaryTeal.opacity(0.5), PulseTheme.primaryTeal.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .scaleEffect(heartbeatScale)
                .opacity(heartbeatOpacity)

            Circle()
                .stroke(PulseTheme.primaryTeal.opacity(0.2), lineWidth: 1)
                .frame(width: 120, height: 120)
                .scaleEffect(heartbeatRingScale)
                .opacity(heartbeatRingOpacity)

            Circle()
                .stroke(PulseTheme.primaryTeal.opacity(0.1), lineWidth: 0.5)
                .frame(width: 160, height: 160)
                .scaleEffect(secondPulseScale)
                .opacity(secondPulseOpacity)

            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 52, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.9, blue: 0.85),
                            PulseTheme.primaryTeal,
                            Color(red: 0.05, green: 0.6, blue: 0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: PulseTheme.primaryTeal.opacity(heartbeatGlowRadius > 0 ? 0.6 : 0), radius: heartbeatGlowRadius)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .rotationEffect(.degrees(logoRotation))
    }

    private var decorativeLine: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.4
            let x = (geo.size.width - w) / 2
            Path { path in
                path.move(to: CGPoint(x: x, y: 1))
                path.addLine(to: CGPoint(x: x + w * horizontalLineProgress, y: 1))
            }
            .stroke(
                LinearGradient(
                    colors: [.clear, PulseTheme.primaryTeal.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: 1
            )
            .opacity(horizontalLineOpacity)
        }
        .frame(height: 2)
    }

    private var wordStack: some View {
        VStack(spacing: 6) {
            wordView("DIAGNOSE", index: 0, color: .white)
            wordView("UNDERSTAND", index: 1, color: .white)
            wordView("EXECUTE", index: 2, color: PulseTheme.primaryTeal)
        }
    }

    private func wordView(_ text: String, index: Int, color: Color) -> some View {
        let revealed = index < wordReveal.count ? wordReveal[index] : false
        let glow = index < wordGlow.count ? wordGlow[index] : 0.0
        return Text(text)
            .font(.system(size: 36, weight: .black, design: .default))
            .tracking(8)
            .foregroundStyle(color)
            .shadow(color: (index == 2 ? PulseTheme.primaryTeal : Color.white).opacity(glow * 0.5), radius: glow * 8)
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed ? 0 : 40)
            .blur(radius: revealed ? 0 : 12)
            .scaleEffect(revealed ? 1 : 0.7)
    }

    private var scoreRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.04), lineWidth: 5)
                .frame(width: 150, height: 150)
                .opacity(ringOpacity)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            PulseTheme.primaryTeal,
                            Color(red: 0.2, green: 0.9, blue: 0.85),
                            Color(red: 0.3, green: 0.95, blue: 0.8),
                            PulseTheme.primaryTeal
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
                .opacity(ringOpacity)
                .shadow(color: PulseTheme.primaryTeal.opacity(ringOpacity * 0.4), radius: 8)

            Circle()
                .trim(from: 0, to: innerRingProgress)
                .stroke(
                    Color.white.opacity(0.08),
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 4])
                )
                .frame(width: 175, height: 175)
                .rotationEffect(.degrees(outerRingRotation))
                .opacity(ringOpacity)

            Text("\(displayNumber)")
                .font(.system(size: 68, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .opacity(scoreOpacity)
                .scaleEffect(scoreScale)
                .contentTransition(.numericText(countsDown: false))
        }
        .scaleEffect(ringScale)
        .frame(height: 190)
    }

    private var tagline: some View {
        Text("Know your number. Own your trajectory.")
            .font(.subheadline.weight(.medium))
            .tracking(2)
            .foregroundStyle(.white.opacity(0.45))
            .opacity(taglineOpacity)
            .offset(y: taglineOffset)
            .blur(radius: taglineBlur)
    }



    private func generateParticles() {
        let screenW: CGFloat = UIScreen.main.bounds.width
        let screenH: CGFloat = UIScreen.main.bounds.height
        particles = (0..<particleCount).map { _ in
            LaunchParticle(
                startX: CGFloat.random(in: -40...screenW + 40),
                startY: CGFloat.random(in: -40...screenH + 40),
                size: CGFloat.random(in: 1...6),
                opacity: Double.random(in: 0.1...0.65),
                speed: Double.random(in: 0.2...1.2),
                phase: Double.random(in: 0...(.pi * 2)),
                amplitude: CGFloat.random(in: 20...80),
                rise: CGFloat.random(in: 2...10),
                delay: Double.random(in: 0...2.0),
                colorType: Int.random(in: 0...3),
                hasGlow: Double.random(in: 0...1) > 0.6
            )
        }
    }

    private func runCinematicSequence() {
        startTime = .now

        // === PHASE 1: Darkness breathing (0-1.5s) ===
        withAnimation(.easeOut(duration: 3.0)) {
            meshGlow = 0.3
        }
        withAnimation(.easeInOut(duration: 5.0).delay(0.5)) {
            meshMorph = true
        }

        // === PHASE 2: Heartbeat pulse from center (1.5s) ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            firstHeartbeat()
        }

        // === PHASE 3: Second heartbeat, logo emerges (2.5s) ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            secondHeartbeat()
        }

        // === PHASE 4: Logo settles, glow radiates (3.5s) ===
        withAnimation(.spring(response: 0.9, dampingFraction: 0.6).delay(3.5)) {
            logoScale = 1.0
            logoRotation = 0
        }
        withAnimation(.easeInOut(duration: 1.5).delay(3.5)) {
            heartbeatGlowRadius = 12
        }
        withAnimation(.easeInOut(duration: 1.0).delay(3.8)) {
            horizontalLineProgress = 1.0
            horizontalLineOpacity = 1.0
        }

        // === PHASE 5: Words slam in one by one (4.2s) ===
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(4.2)) {
            wordReveal[0] = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(4.2)) {
            wordGlow[0] = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(4.5)) {
            wordGlow[0] = 0.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(4.8)) {
            wordReveal[1] = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(4.8)) {
            wordGlow[1] = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(5.1)) {
            wordGlow[1] = 0.0
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(5.4)) {
            wordReveal[2] = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(5.4)) {
            wordGlow[2] = 1.0
        }
        withAnimation(.easeOut(duration: 1.2).delay(5.7)) {
            wordGlow[2] = 0.0
        }

        // === PHASE 6: Mesh intensifies, particles converge (5.0s) ===
        withAnimation(.easeOut(duration: 1.5).delay(5.0)) {
            meshGlow = 1.0
            vignetteDarken = 0.5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
            particleBurst = true
        }

        // === PHASE 7: Shockwave + score ring (5.8s) ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.8) {
            triggerShockwave()
        }

        withAnimation(.spring(response: 0.9, dampingFraction: 0.65).delay(6.0)) {
            ringOpacity = 1
            ringScale = 1.0
        }
        withAnimation(.easeInOut(duration: 1.8).delay(6.1)) {
            ringProgress = 0.88
            innerRingProgress = 1.0
        }
        withAnimation(.linear(duration: 8.0).delay(6.0)) {
            outerRingRotation = 360
        }

        // === PHASE 8: Score number reveal (6.4s) ===
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(6.5)) {
            scoreOpacity = 1
            scoreScale = 1.0
        }
        animateCounter(to: 88, startDelay: 6.6, duration: 1.2)

        // === PHASE 9: Tagline (7.6s) ===
        withAnimation(.easeOut(duration: 1.0).delay(7.8)) {
            taglineOpacity = 1
            taglineOffset = 0
            taglineBlur = 0
        }
        withAnimation(.easeOut(duration: 0.8).delay(7.8)) {
            vignetteDarken = 0.3
        }

        // === PHASE 10: Hold for a beat, then gradual exit (9.5s) ===
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
            beginGradualExit()
        }
    }

    private func firstHeartbeat() {
        withAnimation(.easeOut(duration: 0.25)) {
            heartbeatScale = 1.5
            heartbeatOpacity = 0.8
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.25)) {
            heartbeatScale = 0.8
            heartbeatOpacity = 0.2
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
            heartbeatRingScale = 2.5
            heartbeatRingOpacity = 0.5
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.4)) {
            heartbeatRingOpacity = 0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            logoOpacity = 0.4
            logoScale = 0.6
            logoRotation = -8
        }
    }

    private func secondHeartbeat() {
        withAnimation(.easeOut(duration: 0.2)) {
            heartbeatScale = 2.0
            heartbeatOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.2)) {
            heartbeatScale = 1.2
            heartbeatOpacity = 0.4
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.05)) {
            secondPulseScale = 3.0
            secondPulseOpacity = 0.4
        }
        withAnimation(.easeIn(duration: 0.6).delay(0.35)) {
            secondPulseOpacity = 0
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.65).delay(0.1)) {
            logoOpacity = 1.0
            logoScale = 1.3
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.5)) {
            heartbeatOpacity = 0.6
            heartbeatScale = 1.4
        }
    }

    private func triggerShockwave() {
        withAnimation(.easeOut(duration: 0.6)) {
            shockwaveScale = 5.0
            shockwaveOpacity = 0.6
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
            shockwaveOpacity = 0
        }
        withAnimation(.easeIn(duration: 0.08)) {
            flashOpacity = 0.15
        }
        withAnimation(.easeOut(duration: 0.2).delay(0.08)) {
            flashOpacity = 0
        }
    }

    private func beginGradualExit() {
        withAnimation(.easeInOut(duration: 1.2)) {
            exitScale = 1.08
            meshGlow = 1.5
        }

        withAnimation(.easeIn(duration: 1.8).delay(0.6)) {
            exitBlur = 16
            contentOpacity = 0
        }

        withAnimation(.easeIn(duration: 1.4).delay(0.8)) {
            vignetteDarken = 1.0
        }

        withAnimation(.easeIn(duration: 0.15).delay(1.8)) {
            flashOpacity = 0.5
        }
        withAnimation(.easeOut(duration: 0.5).delay(1.95)) {
            flashOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            timelineActive = false
            onFinished()
        }
    }

    private func animateCounter(to end: Int, startDelay: Double, duration: Double) {
        let steps = end
        let interval = duration / Double(steps)
        for i in 0...steps {
            let eased = Double(i) / Double(steps)
            let curved = eased * eased
            let delay = startDelay + curved * duration
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
