import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    // MARK: - Keys
    
    private enum Keys {
        static let notificationsEnabled = "notificationsEnabled"
        static let taskRemindersEnabled = "taskRemindersEnabled"
        static let aiCheckInsEnabled = "aiCheckInsEnabled"
        static let weeklyReviewEnabled = "weeklyReviewEnabled"
        static let reminderMinutesBefore = "reminderMinutesBefore"
    }
    
    // MARK: - Notification Categories
    
    private enum Category: String {
        case taskReminder = "TASK_REMINDER"
        case aiCheckIn = "AI_CHECK_IN"
        case weeklyReview = "WEEKLY_REVIEW"
        case routineStart = "ROUTINE_START"
    }
    
    private enum Action: String {
        case complete = "COMPLETE"
        case skip = "SKIP"
        case snooze = "SNOOZE"
        case open = "OPEN"
    }
    
    // MARK: - Properties
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Settings
    
    var isNotificationsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.notificationsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.notificationsEnabled) }
    }
    
    var isTaskRemindersEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.taskRemindersEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.taskRemindersEnabled) }
    }
    
    var isAICheckInsEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.aiCheckInsEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.aiCheckInsEnabled) }
    }
    
    var isWeeklyReviewEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.weeklyReviewEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.weeklyReviewEnabled) }
    }
    
    var reminderMinutesBefore: Int {
        get { UserDefaults.standard.integer(forKey: Keys.reminderMinutesBefore).nonZeroOr(5) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.reminderMinutesBefore) }
    }
    
    // MARK: - Init
    
    private override init() {
        super.init()
        center.delegate = self
        registerCategories()
        setDefaultsIfNeeded()
    }
    
    private func setDefaultsIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.notificationsEnabled) == nil {
            defaults.set(true, forKey: Keys.notificationsEnabled)
        }
        if defaults.object(forKey: Keys.taskRemindersEnabled) == nil {
            defaults.set(true, forKey: Keys.taskRemindersEnabled)
        }
        if defaults.object(forKey: Keys.aiCheckInsEnabled) == nil {
            defaults.set(true, forKey: Keys.aiCheckInsEnabled)
        }
        if defaults.object(forKey: Keys.weeklyReviewEnabled) == nil {
            defaults.set(true, forKey: Keys.weeklyReviewEnabled)
        }
    }
    
    // MARK: - Permission
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
                self.isNotificationsEnabled = granted
                completion(granted)
            }
        }
    }
    
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    var isPermissionGranted: Bool {
        var granted = false
        let semaphore = DispatchSemaphore(value: 0)
        center.getNotificationSettings { settings in
            granted = settings.authorizationStatus == .authorized
            semaphore.signal()
        }
        semaphore.wait()
        return granted
    }
    
    // MARK: - Categories Registration
    
    private func registerCategories() {
        let completeAction = UNNotificationAction(
            identifier: Action.complete.rawValue,
            title: "Complete",
            options: [.foreground]
        )
        
        let skipAction = UNNotificationAction(
            identifier: Action.skip.rawValue,
            title: "Skip",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: Action.snooze.rawValue,
            title: "Snooze 5 min",
            options: []
        )
        
        let openAction = UNNotificationAction(
            identifier: Action.open.rawValue,
            title: "Open",
            options: [.foreground]
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: Category.taskReminder.rawValue,
            actions: [completeAction, skipAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        let aiCheckInCategory = UNNotificationCategory(
            identifier: Category.aiCheckIn.rawValue,
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        
        let weeklyReviewCategory = UNNotificationCategory(
            identifier: Category.weeklyReview.rawValue,
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        
        let routineStartCategory = UNNotificationCategory(
            identifier: Category.routineStart.rawValue,
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([
            taskCategory,
            aiCheckInCategory,
            weeklyReviewCategory,
            routineStartCategory
        ])
    }
    
    // MARK: - Schedule Notifications
    
    func scheduleRoutineReminder(routine: RoutineBlock, minutesBefore: Int? = nil) {
        guard isNotificationsEnabled && isTaskRemindersEnabled else { return }
        
        let reminderMinutes = minutesBefore ?? reminderMinutesBefore
        
        for task in routine.tasks {
            guard !task.isBreak else { continue }
            
            guard let notificationTime = calculateNotificationTime(
                taskStartTime: task.startTime,
                routineStartTime: routine.startTime,
                minutesBefore: reminderMinutes
            ) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Upcoming: \(task.title)"
            content.body = "Starting in \(reminderMinutes) minutes"
            content.sound = .default
            content.categoryIdentifier = Category.taskReminder.rawValue
            content.userInfo = [
                "taskId": task.id,
                "routineId": routine.id,
                "type": "taskReminder"
            ]
            
            scheduleNotification(
                content: content,
                identifier: "task_\(task.id)",
                date: notificationTime
            )
        }
    }
    
    func scheduleRoutineStartNotification(routine: RoutineBlock) {
        guard isNotificationsEnabled && isTaskRemindersEnabled else { return }
        
        guard let startTime = parseTime(routine.startTime) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for \(routine.title)"
        content.body = routine.description ?? "Your routine is ready to start"
        content.sound = .default
        content.categoryIdentifier = Category.routineStart.rawValue
        content.userInfo = [
            "routineId": routine.id,
            "type": "routineStart"
        ]
        
        scheduleNotification(
            content: content,
            identifier: "routine_start_\(routine.id)",
            date: startTime
        )
    }
    
    func scheduleAICheckIn(routineId: String, taskId: String, message: String) {
        guard isNotificationsEnabled && isAICheckInsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "How's it going?"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = Category.aiCheckIn.rawValue
        content.userInfo = [
            "routineId": routineId,
            "taskId": taskId,
            "type": "aiCheckIn"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(
            identifier: "ai_checkin_\(taskId)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func scheduleRoutineCompletionCheck(routine: RoutineBlock) {
        guard isNotificationsEnabled && isAICheckInsEnabled else { return }
        
        guard let endTime = parseTime(routine.endTime) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Routine Complete!"
        content.body = "Did you complete all tasks in \(routine.title)?"
        content.sound = .default
        content.categoryIdentifier = Category.aiCheckIn.rawValue
        content.userInfo = [
            "routineId": routine.id,
            "type": "routineCompletion"
        ]
        
        scheduleNotification(
            content: content,
            identifier: "routine_complete_\(routine.id)",
            date: endTime
        )
    }
    
    func scheduleWeeklyReview(day: Int = 1, hour: Int = 20, minute: Int = 0) {
        guard isNotificationsEnabled && isWeeklyReviewEnabled else { return }
        
        cancelWeeklyReview()
        
        var dateComponents = DateComponents()
        dateComponents.weekday = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Review"
        content.body = "Time to review your week and plan ahead!"
        content.sound = .default
        content.categoryIdentifier = Category.weeklyReview.rawValue
        content.userInfo = ["type": "weeklyReview"]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly_review",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func cancelWeeklyReview() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_review"])
    }
    
    // MARK: - Cancel Notifications
    
    func cancelRoutineNotifications(routineId: String) {
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(routineId) }
                .map { $0.identifier }
            self.center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    func cancelTaskNotification(taskId: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["task_\(taskId)"])
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Helpers
    
    private func scheduleNotification(content: UNMutableNotificationContent, identifier: String, date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateNotificationTime(taskStartTime: String, routineStartTime: String, minutesBefore: Int) -> Date? {
        let today = Date()
        let calendar = Calendar.current
        
        guard let taskDate = parseTimeToDate(taskStartTime, baseDate: today) else { return nil }
        
        let notificationDate = calendar.date(byAdding: .minute, value: -minutesBefore, to: taskDate)
        
        if let notificationDate = notificationDate, notificationDate > Date() {
            return notificationDate
        }
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)
        return parseTimeToDate(taskStartTime, baseDate: tomorrow!)
    }
    
    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let baseDate = Date()
        return formatter.date(from: timeString).map { time in
            calendar.date(
                bySettingHour: calendar.component(.hour, from: time),
                minute: calendar.component(.minute, from: time),
                second: 0,
                of: baseDate
            )
        } ?? nil
    }
    
    private func parseTimeToDate(_ timeString: String, baseDate: Date) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let time = formatter.date(from: timeString) else { return nil }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate)
    }
    
    private var calendar: Calendar {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case Action.complete.rawValue:
            handleTaskComplete(userInfo: userInfo)
        case Action.skip.rawValue:
            handleTaskSkip(userInfo: userInfo)
        case Action.snooze.rawValue:
            handleTaskSnooze(userInfo: userInfo)
        case Action.open.rawValue, UNNotificationDefaultActionIdentifier:
            handleNotificationOpen(userInfo: userInfo)
        default:
            break
        }
        
        completionHandler()
    }
    
    private func handleTaskComplete(userInfo: [AnyHashable: Any]) {
        guard let taskId = userInfo["taskId"] as? String else { return }
        NotificationCenter.default.post(
            name: .taskCompleted,
            object: nil,
            userInfo: ["taskId": taskId]
        )
    }
    
    private func handleTaskSkip(userInfo: [AnyHashable: Any]) {
        guard let taskId = userInfo["taskId"] as? String,
              let routineId = userInfo["routineId"] as? String else { return }
        NotificationCenter.default.post(
            name: .taskSkipped,
            object: nil,
            userInfo: ["taskId": taskId, "routineId": routineId]
        )
    }
    
    private func handleTaskSnooze(userInfo: [AnyHashable: Any]) {
        guard let taskId = userInfo["taskId"] as? String else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Time to complete your task!"
        content.sound = .default
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let request = UNNotificationRequest(
            identifier: "snooze_\(taskId)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    private func handleNotificationOpen(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        
        var notificationName: Notification.Name = .notificationOpened
        if type == "routineCompletion" {
            notificationName = .routineCompletion
        }
        
        NotificationCenter.default.post(
            name: notificationName,
            object: nil,
            userInfo: ["type": type, "data": userInfo]
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let taskCompleted = Notification.Name("NotificationManager.taskCompleted")
    static let taskSkipped = Notification.Name("NotificationManager.taskSkipped")
    static let notificationOpened = Notification.Name("NotificationManager.notificationOpened")
    static let routineCompletion = Notification.Name("NotificationManager.routineCompletion")
}

// MARK: - Int Extension

private extension Int {
    func nonZeroOr(_ defaultValue: Int) -> Int {
        self != 0 ? self : defaultValue
    }
}
