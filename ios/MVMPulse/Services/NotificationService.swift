import Foundation
import UserNotifications

@Observable
@MainActor
final class NotificationService {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    var isAuthorized: Bool = false
    
    private init() {
        Task { await checkAuthorization() }
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }
    
    func checkAuthorization() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_task_reminder"])
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "MVM Pulse"
        content.body = "Your daily task is waiting. 5 minutes to keep the momentum."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "daily_task_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func scheduleStreakReminder(hour: Int = 20, minute: Int = 0) {
        center.removePendingNotificationRequests(withIdentifiers: ["streak_reminder"])
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak"
        content.body = "You haven't completed today's task yet. It only takes a few minutes."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }
    
    func updateNotifications(enabled: Bool) {
        if enabled {
            Task {
                let granted = await requestPermission()
                if granted {
                    scheduleDailyReminder()
                    scheduleStreakReminder()
                }
            }
        } else {
            cancelAllReminders()
        }
    }
}
