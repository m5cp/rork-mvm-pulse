import SwiftUI

struct TaskCompletionOverlay: View {
    @Binding var isShowing: Bool
    @State private var checkScale: CGFloat = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0
    @State private var confettiPhase: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { isShowing = false }

            if !reduceMotion {
                ConfettiLayer(phase: confettiPhase)
                    .allowsHitTesting(false)
            }

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.12))
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)

                    Circle()
                        .fill(PulseTheme.primaryTeal)
                        .frame(width: 72, height: 72)
                        .scaleEffect(checkScale)

                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(checkScale)
                }

                VStack(spacing: 6) {
                    Text("Task Complete!")
                        .font(.title3.bold())
                    Text("Keep the momentum going")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(textOpacity)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 28))
        }
        .onAppear {
            if reduceMotion {
                checkScale = 1
                ringScale = 1
                textOpacity = 1
                autoDismiss()
                return
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                ringScale = 1
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5).delay(0.15)) {
                checkScale = 1
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                textOpacity = 1
            }
            confettiPhase += 1
            autoDismiss()
        }
    }

    private func autoDismiss() {
        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.3)) {
                isShowing = false
            }
        }
    }
}
