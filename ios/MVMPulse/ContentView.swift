import SwiftUI

struct ContentView: View {
    @State private var storage = StorageService()
    @State private var store = StoreViewModel()
    @State private var ai = AIViewModel()
    @State private var selectedTab: AppTab = .dashboard
    @State private var showOnboarding: Bool = false
    @State private var showLaunch: Bool = true

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Dashboard", systemImage: "square.grid.2x2.fill", value: .dashboard) {
                    DashboardView(storage: storage, store: store, ai: ai, selectedTab: $selectedTab)
                }

                Tab("Assess", systemImage: "waveform.path.ecg", value: .assess) {
                    AssessTabView(storage: storage, store: store, ai: ai)
                }

                Tab("Coach", systemImage: "sparkles", value: .coach) {
                    AIChatView(storage: storage, store: store, ai: ai)
                }

                Tab("Roadmap", systemImage: "map.fill", value: .roadmap) {
                    RoadmapView(storage: storage, store: store, ai: ai)
                }

                Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                    SettingsView(storage: storage, store: store)
                }
            }
            .tint(PulseTheme.primaryTeal)
            .opacity(showLaunch ? 0 : 1)
            .sensoryFeedback(.selection, trigger: selectedTab)

            if showLaunch {
                LaunchAnimationView {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showLaunch = false
                    }
                    if !storage.userProfile.hasCompletedOnboarding {
                        showOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(storage: storage) {
                showOnboarding = false
            }
        }
        .preferredColorScheme(colorScheme)
    }

    private var colorScheme: ColorScheme? {
        switch storage.appearanceMode {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

struct AssessTabView: View {
    let storage: StorageService
    let store: StoreViewModel
    let ai: AIViewModel
    @State private var showAssessment: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 48))
                        .foregroundStyle(PulseTheme.primaryTeal)

                    VStack(spacing: 8) {
                        Text(storage.hasCompletedAssessment ? "Take a New Assessment" : "Start Your Assessment")
                            .font(.title2.bold())

                        Text("24 core questions across 8 dimensions.\nAbout 2\u{2013}3 minutes to complete.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    if storage.hasCompletedAssessment, let latest = storage.latestResult {
                        HStack(spacing: 8) {
                            Text("Current score:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(Int(latest.overallScore))")
                                .font(.subheadline.bold())
                                .foregroundStyle(PulseTheme.scoreColor(for: latest.overallScore))
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    showAssessment = true
                } label: {
                    Text("Begin Assessment")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(PulseTheme.primaryTeal)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .sensoryFeedback(.impact(weight: .medium), trigger: showAssessment)
            }
            .navigationTitle("Assess")
            .fullScreenCover(isPresented: $showAssessment) {
                NavigationStack {
                    AssessmentFlowContainer(storage: storage, store: store, ai: ai, selectedTab: .constant(.assess), mode: .quick)
                }
            }
        }
    }
}
