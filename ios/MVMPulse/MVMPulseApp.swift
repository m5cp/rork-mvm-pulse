import SwiftUI
import AppIntents

@main
struct MVMPulseApp: App {
    init() {
        MVMPulseShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
