import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let storage: StorageService
    let store: StoreViewModel
    @State private var showResetConfirmation: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showLegal: LegalPage?
    @State private var editingProfile: Bool = false
    @State private var showExporter: Bool = false
    @State private var showImporter: Bool = false
    @State private var importResult: ImportResult?
    @State private var showAssessmentHistory: Bool = false
    @State private var showGoalSetting: Bool = false
    @State private var morningTime: Date = Date()
    @State private var eveningTime: Date = Date()

    enum ImportResult: Identifiable {
        case success, failure
        var id: String {
            switch self {
            case .success: return "success"
            case .failure: return "failure"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                profileSection
                notificationsSection
                appearanceSection
                goalSection
                historySection
                subscriptionSection
                dataManagementSection
                legalSection
                supportSection
                resetSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $editingProfile) {
                NavigationStack {
                    ProfileEditView(storage: storage)
                }
            }
            .sheet(isPresented: $showPaywall) {
                NavigationStack {
                    PaywallView(store: store)
                }
            }
            .sheet(item: $showLegal) { page in
                NavigationStack {
                    LegalPageView(page: page)
                }
            }
            .sheet(isPresented: $showAssessmentHistory) {
                NavigationStack {
                    AssessmentHistoryView(storage: storage, store: store)
                }
            }
            .sheet(isPresented: $showGoalSetting) {
                NavigationStack {
                    GoalSettingView(storage: storage)
                }
            }
            .alert("Reset All Data", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) {
                    storage.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your assessments, roadmap progress, and streak data. This cannot be undone.")
            }
            .alert(item: $importResult) { result in
                switch result {
                case .success:
                    return Alert(
                        title: Text("Import Successful"),
                        message: Text("Your data has been restored."),
                        dismissButton: .default(Text("OK"))
                    )
                case .failure:
                    return Alert(
                        title: Text("Import Failed"),
                        message: Text("The file could not be read. Make sure it is a valid MVM Pulse backup file."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: PulseDataDocument(data: DataExportService.exportData(from: storage)),
                contentType: .json,
                defaultFilename: "MVMPulse_Backup_\(formattedDate).json"
            ) { _ in }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else {
                        importResult = .failure
                        return
                    }
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url),
                       DataExportService.importData(data, into: storage) {
                        importResult = .success
                    } else {
                        importResult = .failure
                    }
                case .failure:
                    importResult = .failure
                }
            }
            .onAppear {
                syncTimePickers()
            }
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private func syncTimePickers() {
        var morningComponents = DateComponents()
        morningComponents.hour = storage.morningReminderHour
        morningComponents.minute = storage.morningReminderMinute
        morningTime = Calendar.current.date(from: morningComponents) ?? Date()

        var eveningComponents = DateComponents()
        eveningComponents.hour = storage.eveningReminderHour
        eveningComponents.minute = storage.eveningReminderMinute
        eveningTime = Calendar.current.date(from: eveningComponents) ?? Date()
    }

    private var profileSection: some View {
        Section("Profile") {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PulseTheme.primaryTeal.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(String(storage.userProfile.firstName.prefix(1)).uppercased())
                        .font(.title3.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(storage.userProfile.firstName.isEmpty ? "Set up profile" : storage.userProfile.firstName)
                        .font(.body.bold())
                    Text("\(storage.userProfile.role.rawValue) \u{00B7} \(storage.userProfile.industry.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { editingProfile = true }
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle("Daily Reminders", isOn: .init(
                get: { storage.notificationsEnabled },
                set: { newValue in
                    storage.notificationsEnabled = newValue
                    if newValue {
                        updateNotificationTimes()
                    } else {
                        NotificationService.shared.updateNotifications(enabled: false)
                    }
                }
            ))

            if storage.notificationsEnabled {
                DatePicker("Morning reminder", selection: $morningTime, displayedComponents: .hourAndMinute)
                    .font(.subheadline)
                    .onChange(of: morningTime) { _, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        storage.morningReminderHour = components.hour ?? 9
                        storage.morningReminderMinute = components.minute ?? 0
                        updateNotificationTimes()
                    }

                DatePicker("Evening nudge", selection: $eveningTime, displayedComponents: .hourAndMinute)
                    .font(.subheadline)
                    .onChange(of: eveningTime) { _, newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        storage.eveningReminderHour = components.hour ?? 20
                        storage.eveningReminderMinute = components.minute ?? 0
                        updateNotificationTimes()
                    }
            }
        } header: {
            Text("Notifications")
        } footer: {
            if storage.notificationsEnabled {
                Text("You'll get a morning reminder for your daily task and an evening nudge if you haven't completed it yet.")
            }
        }
    }

    private func updateNotificationTimes() {
        NotificationService.shared.scheduleDailyReminder(
            hour: storage.morningReminderHour,
            minute: storage.morningReminderMinute
        )
        NotificationService.shared.scheduleStreakReminder(
            hour: storage.eveningReminderHour,
            minute: storage.eveningReminderMinute
        )
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: .init(
                get: { storage.appearanceMode },
                set: { storage.appearanceMode = $0 }
            )) {
                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
        }
    }

    private var goalSection: some View {
        Section("Goal") {
            if let goal = storage.goalData, let result = storage.latestResult {
                let pointsLeft = max(0, Int(goal.targetScore) - Int(result.overallScore))
                let daysLeft = max(0, Calendar.current.dateComponents([.day], from: Date(), to: goal.targetDate).day ?? 0)

                Button {
                    showGoalSetting = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target: \(Int(goal.targetScore))")
                                .font(.subheadline.bold())
                                .foregroundStyle(.primary)
                            if pointsLeft > 0 {
                                Text("\(pointsLeft) points to go \u{00B7} \(daysLeft) days left")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Goal reached!")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                Button {
                    showGoalSetting = true
                } label: {
                    HStack {
                        Label("Set a Score Goal", systemImage: "target")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private var historySection: some View {
        Section("History") {
            Button {
                showAssessmentHistory = true
            } label: {
                HStack {
                    Label("Assessment History", systemImage: "clock.arrow.circlepath")
                        .foregroundStyle(.primary)
                    Spacer()
                    if !storage.assessmentResults.isEmpty {
                        Text("\(storage.assessmentResults.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if !storage.dailyCheckIns.isEmpty {
                HStack {
                    Label("Check-ins", systemImage: "heart.text.square")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(storage.dailyCheckIns.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var subscriptionSection: some View {
        Section("Subscription") {
            if store.isPremium {
                HStack {
                    Label("Business", systemImage: "building.2.fill")
                        .foregroundStyle(PulseTheme.primaryTeal)
                    Spacer()
                    Text("Active")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    HStack {
                        Label("Upgrade to Business", systemImage: "building.2.fill")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private var dataManagementSection: some View {
        Section {
            Button {
                showExporter = true
            } label: {
                HStack {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Button {
                showImporter = true
            } label: {
                HStack {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        } header: {
            Text("Data")
        } footer: {
            Text("Export creates a backup of all your assessments, roadmap, and progress. Import restores from a previous backup.")
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            ForEach(LegalPage.allCases, id: \.self) { page in
                Button {
                    showLegal = page
                } label: {
                    HStack {
                        Text(page.title)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            if let url = URL(string: "mailto:contact@m5cairo.com") {
                Link(destination: url) {
                    HStack {
                        Label("Contact Support", systemImage: "envelope")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if let siteURL = URL(string: "https://m5cairo.com") {
                Link(destination: siteURL) {
                    HStack {
                        Label("Visit m5cairo.com", systemImage: "globe")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if let consultURL = URL(string: "https://m5cairo.com") {
                Link(destination: consultURL) {
                    HStack {
                        Label("Book a Consultation", systemImage: "person.2.fill")
                            .foregroundStyle(PulseTheme.primaryTeal)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text("Built by")
                Spacer()
                Text("M5CAIRO")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var resetSection: some View {
        Section {
            Button("Reset All Data", role: .destructive) {
                showResetConfirmation = true
            }
        } footer: {
            Text("All data is stored exclusively on your device. No personal information is collected or transmitted.")
                .font(.caption2)
        }
    }
}

struct PulseDataDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let data: Data?

    init(data: Data?) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data ?? Data())
    }
}

struct ProfileEditView: View {
    let storage: StorageService
    @State private var firstName: String = ""
    @State private var role: UserRole = .individual
    @State private var industry: Industry = .technology
    @State private var companySize: CompanySize = .solo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Name") {
                TextField("First name", text: $firstName)
                    .textContentType(.givenName)
            }

            Section("Role") {
                Picker("Role", selection: $role) {
                    ForEach(UserRole.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Industry") {
                Picker("Industry", selection: $industry) {
                    ForEach(Industry.allCases, id: \.self) { i in
                        Text(i.rawValue).tag(i)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Company Size") {
                Picker("Company Size", selection: $companySize) {
                    ForEach(CompanySize.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    storage.userProfile.firstName = firstName.trimmingCharacters(in: .whitespaces)
                    storage.userProfile.role = role
                    storage.userProfile.industry = industry
                    storage.userProfile.companySize = companySize
                    dismiss()
                }
                .disabled(firstName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            firstName = storage.userProfile.firstName
            role = storage.userProfile.role
            industry = storage.userProfile.industry
            companySize = storage.userProfile.companySize
        }
    }
}

enum LegalPage: String, CaseIterable, Identifiable, Sendable {
    case privacy = "Privacy Policy"
    case terms = "Terms of Use"
    case disclaimer = "Disclaimer"
    case accessibility = "Accessibility Statement"
    case eula = "EULA"

    var id: String { rawValue }
    var title: String { rawValue }

    var content: String {
        switch self {
        case .privacy:
            return "MVM Pulse stores all data exclusively on your device. Your assessment responses, scores, roadmap progress, and history never leave your device.\n\nEmail Collection: If you optionally provide your email address during the results flow, it is stored locally on your device for contact purposes only. It is not transmitted to any server, shared with third parties, or used for marketing.\n\nPremium purchases are processed securely by Apple through the App Store. We do not have access to your payment information.\n\nWe do not use analytics, advertising, or tracking SDKs of any kind. No personal data is collected, transmitted, or shared with any third party.\n\nFor questions about your privacy, contact: contact@m5cairo.com"
        case .terms:
            return "MVM Pulse is a self-assessment and personal development tool provided for informational purposes only. It does not constitute financial advice, medical advice, legal advice, business consulting, or any other form of professional guidance. Scores and recommendations are algorithmically generated based on self-reported information and general benchmarks. Individual results will vary. Consult qualified professionals for specific advice.\n\nThis app is licensed under Apple's Standard EULA. M5 Capital Partners LLC reserves all intellectual property rights."
        case .disclaimer:
            return "MVM Pulse is not a substitute for professional financial planning, business consulting, medical care, therapy, or any licensed professional service. All scores, insights, roadmaps, and recommendations are estimates based on your self-reported answers and general industry research. Every individual and business situation is different.\n\nM5 Capital Partners LLC (M5CAIRO) makes no guarantees regarding specific outcomes from using this app. Use at your own discretion."
        case .accessibility:
            return "MVM Pulse supports VoiceOver with descriptive labels on interactive elements, Dynamic Type for text scaling, full Dark Mode, Reduce Motion preference, and minimum 44x44 point touch targets.\n\nContact contact@m5cairo.com with accessibility feedback."
        case .eula:
            return "This app is licensed under Apple's Standard End User License Agreement (EULA).\n\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        }
    }
}

struct LegalPageView: View {
    let page: LegalPage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            Text(page.content)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(20)
        }
        .navigationTitle(page.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}
