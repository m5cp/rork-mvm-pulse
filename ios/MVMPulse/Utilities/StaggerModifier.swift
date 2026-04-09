import SwiftUI

struct StaggerIn: ViewModifier {
    let appeared: Bool
    let index: Int
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .animation(
                reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.78).delay(Double(index) * 0.07),
                value: appeared
            )
    }
}

extension View {
    func staggerIn(appeared: Bool, index: Int, reduceMotion: Bool) -> some View {
        modifier(StaggerIn(appeared: appeared, index: index, reduceMotion: reduceMotion))
    }
}
