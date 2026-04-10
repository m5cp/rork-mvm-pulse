import SwiftUI
import AppIntents
import RevenueCat

@main
struct MVMPulseApp: App {
    init() {
        MVMPulseShortcuts.updateAppShortcutParameters()
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
