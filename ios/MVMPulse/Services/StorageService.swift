import Foundation

@Observable
@MainActor
final class StorageService {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let userProfile = "mvmpulse_user_profile"
        static let assessmentResults = "mvmpulse_assessment_results"
        static let roadmap = "mvmpulse_roadmap"
        static let streakData = "mvmpulse_streak_data"
        static let appearanceMode = "mvmpulse_appearance_mode"
        static let notificationsEnabled = "mvmpulse_notifications_enabled"
        static let dailyCheckIns = "mvmpulse_daily_checkins"
        static let goalData = "mvmpulse_goal_data"
        static let morningReminderHour = "mvmpulse_morning_reminder_hour"
        static let morningReminderMinute = "mvmpulse_morning_reminder_minute"
        static let eveningReminderHour = "mvmpulse_evening_reminder_hour"
        static let eveningReminderMinute = "mvmpulse_evening_reminder_minute"
        static let teamData = "mvmpulse_team_data"
    }

    var userProfile: UserProfile {
        didSet { save(userProfile, forKey: Keys.userProfile) }
    }

    var assessmentResults: [AssessmentResult] {
        didSet { save(assessmentResults, forKey: Keys.assessmentResults) }
    }

    var roadmap: Roadmap {
        didSet { save(roadmap, forKey: Keys.roadmap) }
    }

    var streakData: StreakData {
        didSet { save(streakData, forKey: Keys.streakData) }
    }

    var appearanceMode: AppearanceMode {
        didSet { save(appearanceMode, forKey: Keys.appearanceMode) }
    }

    var notificationsEnabled: Bool {
        didSet {
            defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
            NotificationService.shared.updateNotifications(enabled: notificationsEnabled)
        }
    }

    var dailyCheckIns: [DailyCheckIn] {
        didSet { save(dailyCheckIns, forKey: Keys.dailyCheckIns) }
    }

    var goalData: GoalData? {
        didSet { save(goalData, forKey: Keys.goalData) }
    }

    var teamData: TeamAssessmentData? {
        didSet { save(teamData, forKey: Keys.teamData) }
    }

    var morningReminderHour: Int {
        didSet { defaults.set(morningReminderHour, forKey: Keys.morningReminderHour) }
    }

    var morningReminderMinute: Int {
        didSet { defaults.set(morningReminderMinute, forKey: Keys.morningReminderMinute) }
    }

    var eveningReminderHour: Int {
        didSet { defaults.set(eveningReminderHour, forKey: Keys.eveningReminderHour) }
    }

    var eveningReminderMinute: Int {
        didSet { defaults.set(eveningReminderMinute, forKey: Keys.eveningReminderMinute) }
    }

    var hasCheckedInToday: Bool {
        guard let last = dailyCheckIns.last else { return false }
        return Calendar.current.isDateInToday(last.date)
    }

    var latestResult: AssessmentResult? {
        assessmentResults.last
    }

    var hasCompletedAssessment: Bool {
        !assessmentResults.isEmpty
    }

    init() {
        self.userProfile = Self.load(UserProfile.self, forKey: Keys.userProfile) ?? UserProfile()
        self.assessmentResults = Self.load([AssessmentResult].self, forKey: Keys.assessmentResults) ?? []
        self.roadmap = Self.load(Roadmap.self, forKey: Keys.roadmap) ?? Roadmap()
        self.streakData = Self.load(StreakData.self, forKey: Keys.streakData) ?? StreakData()
        self.appearanceMode = Self.load(AppearanceMode.self, forKey: Keys.appearanceMode) ?? .system
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
        self.dailyCheckIns = Self.load([DailyCheckIn].self, forKey: Keys.dailyCheckIns) ?? []
        self.goalData = Self.load(GoalData.self, forKey: Keys.goalData)
        self.teamData = Self.load(TeamAssessmentData.self, forKey: Keys.teamData)
        self.morningReminderHour = UserDefaults.standard.object(forKey: Keys.morningReminderHour) as? Int ?? 9
        self.morningReminderMinute = UserDefaults.standard.object(forKey: Keys.morningReminderMinute) as? Int ?? 0
        self.eveningReminderHour = UserDefaults.standard.object(forKey: Keys.eveningReminderHour) as? Int ?? 20
        self.eveningReminderMinute = UserDefaults.standard.object(forKey: Keys.eveningReminderMinute) as? Int ?? 0
    }

    func recordActivity() {
        let now = Date()
        if streakData.streakBroken {
            streakData.currentStreak = 1
        } else if !streakData.isActiveToday {
            streakData.currentStreak += 1
        }
        streakData.lastActivityDate = now
        if !streakData.isActiveToday {
            streakData.totalDaysActive += 1
        }
        if streakData.currentStreak > streakData.longestStreak {
            streakData.longestStreak = streakData.currentStreak
        }
        checkMilestones()
    }

    func checkMilestones() {
        for threshold in StreakMilestone.milestoneThresholds {
            if streakData.currentStreak >= threshold &&
                !streakData.milestones.contains(where: { $0.days == threshold }) {
                let milestone = StreakMilestone(
                    id: UUID().uuidString,
                    days: threshold,
                    title: "\(threshold)-Day Streak",
                    achievedDate: Date()
                )
                streakData.milestones.append(milestone)
            }
        }
    }

    func resetAllData() {
        userProfile = UserProfile()
        assessmentResults = []
        roadmap = Roadmap()
        streakData = StreakData()
        dailyCheckIns = []
        goalData = nil
        teamData = nil
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    nonisolated private static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
