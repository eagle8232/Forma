//
//  HomeViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/25/26.
//

import SwiftUI
import Combine
import UserNotifications

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Load State

    enum LoadState {
        case idle
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Published

    @Published var routines: [RoutineBlock] = []
    @Published var activeRoutine: RoutineBlock? = nil
    @Published var tasks: [RoutineTask] = []
    @Published var user: User? = nil
    @Published var progress: Double = 0
    @Published var currentTask: RoutineTask? = nil
    @Published var now: Date = Date()
    @Published var loadState: LoadState = .idle
    @Published var shouldShowCompletionSheet: Bool = false
    @Published var pendingRoutineIds: [String] = []

    // MARK: - Private

    private var timer: AnyCancellable?
    private let initialRoutines: [RoutineBlock]?
    private var completedRoutineIds: Set<String> = []
    private var hasCheckedTodayCompletions: Bool = false

    // MARK: - Computed

    var accent: Color {
        guard let routine = activeRoutine else { return AppColor.accentPrimary }
        return Color(uiColor: UIColor(hex: routine.accentColor))
    }

    var weekdayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: now).uppercased()
    }

    var dateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d"
        return f.string(from: now)
    }

    var formattedStartTime: String {
        guard let r = activeRoutine else { return "--:--" }
        return r.startTime
    }

    var formattedEndTime: String {
        guard let r = activeRoutine else { return "--:--" }
        return r.endTime
    }

    var formattedNow: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: now)
    }

    // MARK: - Init

    init(routines: [RoutineBlock]? = nil) {
        self.initialRoutines = routines
    }
    
    // MARK: - Computed (sorted tasks)

    var sortedTasks: [RoutineTask] {
        let uniqueTasks = removeDuplicates(from: tasks)
        return uniqueTasks.sorted { t1, t2 in
            DateManager.shared.convertToSeconds(string: t1.startTime) < DateManager.shared.convertToSeconds(string: t2.startTime)
        }
    }
    
    private func removeDuplicates(from tasks: [RoutineTask]) -> [RoutineTask] {
        var seen = Set<String>()
        return tasks.filter { task in
            if seen.contains(task.id) {
                return false
            }
            seen.insert(task.id)
            return true
        }
    }
    
    // MARK: - Streak Data
    
    var streakData: StreakData {
        let currentStreak = CompletionService.shared.getStreak()
        let weeklyStats = CompletionService.shared.getWeeklyStats()
        let completionRate = weeklyStats.completedRoutines > 0 ? 1.0 : 0.0
        
        return StreakData(
            currentStreak: currentStreak,
            bestStreak: max(currentStreak, 1),
            totalDays: currentStreak,
            completionRate: completionRate,
            weekDays: generateWeekDays()
        )
    }
    
    private func generateWeekDays() -> [StreakData.DayEntry] {
        let calendar = Calendar.current
        let today = Date()
        
        let weekdayLabels: [Int: String] = [
            1: "S", 2: "M", 3: "T", 4: "W", 5: "T", 6: "F", 7: "S"
        ]
        
        let weekStart: Date
        if let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
            weekStart = monday
        } else {
            let currentWeekday = calendar.component(.weekday, from: today)
            let daysToSubtract = (currentWeekday - calendar.firstWeekday + 7) % 7
            weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        }
        
        var entries: [StreakData.DayEntry] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: weekStart) else { continue }
            
            let weekday = calendar.component(.weekday, from: date)
            let label = weekdayLabels[weekday] ?? "M"
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today
            
            let stats = CompletionService.shared.getStats(for: date)
            let completion = stats.score > 0 ? Double(stats.score) / 100.0 : 0.0
            
            let state: StreakData.DayEntry.DayState
            if isFuture {
                state = .future
            } else if isToday {
                state = .today
            } else if completion >= 0.8 {
                state = .completed
            } else if completion >= 0.3 {
                state = .partial
            } else {
                state = .missed
            }
            
            entries.append(StreakData.DayEntry(
                label: label,
                state: state,
                completion: completion
            ))
        }
        
        return entries
    }

    // MARK: - Load

    func load() async {
        loadState = .loading
        
        completedRoutineIds.removeAll()
        pendingRoutineIds = []
        shouldShowCompletionSheet = false
        
        if let preloaded = initialRoutines, !preloaded.isEmpty {
            routines = preloaded.sorted { $0.startTime < $1.startTime }
        } else {
            routines = (DependencyContainer.shared.routines ?? []).sorted { $0.startTime < $1.startTime }
        }
        
        if let containerUser = DependencyContainer.shared.currentUser {
            user = containerUser
        }
        
        prePopulateCompletedRoutineIds()
        
        activeRoutine = computeActiveRoutine()
        tasks         = activeRoutine?.tasks ?? []
        recalculate()
        loadState = .loaded
        
        requestNotificationPermissionIfNeeded()
        scheduleNotificationsForRoutines()
    }
    
    private func prePopulateCompletedRoutineIds() {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id else { return }
        
        let recentlyCreated = UserDefaults.standard.object(forKey: "routinesRecentlyCreatedAt") as? Date
        let isRecentCreation = recentlyCreated != nil && Date().timeIntervalSince(recentlyCreated!) < 300
        
        for routine in routines {
            if CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) != nil {
                completedRoutineIds.insert(routine.id)
            } else if isRecentCreation {
                completedRoutineIds.insert(routine.id)
            }
        }
        
        if isRecentCreation {
            UserDefaults.standard.removeObject(forKey: "routinesRecentlyCreatedAt")
        }
    }
    
    private func requestNotificationPermissionIfNeeded() {
        NotificationManager.shared.checkPermissionStatus { [weak self] (status: UNAuthorizationStatus) in
            switch status {
            case .notDetermined:
                NotificationManager.shared.requestPermission { granted in
                    if granted {
                        self?.scheduleNotificationsForRoutines()
                    }
                }
            case .authorized:
                self?.scheduleNotificationsForRoutines()
            default:
                break
            }
        }
    }
    
    private func scheduleNotificationsForRoutines() {
        guard NotificationManager.shared.isNotificationsEnabled else { return }
        
        for routine in routines {
            NotificationManager.shared.scheduleRoutineReminder(routine: routine)
            NotificationManager.shared.scheduleRoutineStartNotification(routine: routine)
        }
        
        NotificationManager.shared.scheduleWeeklyReview()
    }

    // MARK: - Timer

    func startLiveTimer() {
        recalculate()
        timer = Timer
            .publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.recalculate() }
    }

    func stopLiveTimer() {
        timer?.cancel()
        timer = nil
    }

    // MARK: - Task mutation

    func updateRoutine(_ updated: RoutineBlock) {
        guard let i = routines.firstIndex(where: { $0.id == updated.id }) else { return }
        routines[i]   = updated
        activeRoutine = updated
        tasks         = updated.tasks
        recalculate()
    }

    func selectRoutine(at index: Int) {
        guard index >= 0, index < routines.count else { return }
        activeRoutine = routines[index]
        tasks         = activeRoutine?.tasks ?? []
        now           = Date()
        updateTaskStates()
        progress    = computeRoutineProgress()
        currentTask = computeCurrentTask()
    }

    func progressFor(_ routine: RoutineBlock) -> Double {
        
        let now = DateManager.shared.convertToSeconds(date: now)
        let start = DateManager.shared.convertToSeconds(string: routine.startTime)
        let end   = DateManager.shared.convertToSeconds(string: routine.endTime)
        
        let total = end - start
        let elapsed = now - start
        
        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }

    func isRoutineCompleted(_ routine: RoutineBlock) -> Bool {
        let endTimeInSeconds     = DateManager.shared.convertToSeconds(string: routine.endTime)
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: now)
        return currentTimeInSeconds >= endTimeInSeconds
    }

    func isRoutineUpcoming(_ routine: RoutineBlock) -> Bool {
        let startTimeInSeconds   = DateManager.shared.convertToSeconds(string: routine.startTime)
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: now)
        return currentTimeInSeconds < startTimeInSeconds
    }
    
    func dismissCompletionSheet() {
        shouldShowCompletionSheet = false
    }
    
    func clearPendingRoutine() {
        pendingRoutineIds = []
    }
    
    func markRoutineAsCompleted(_ routineId: String) {
        completedRoutineIds.insert(routineId)
        pendingRoutineIds.removeAll { $0 == routineId }
        if pendingRoutineIds.isEmpty {
            shouldShowCompletionSheet = false
        }
    }
    
    func getPendingRoutines() -> [RoutineBlock] {
        pendingRoutineIds.compactMap { id in
            routines.first { $0.id == id }
        }
    }
}

// MARK: - Private helpers

private extension HomeViewModel {

    func computeActiveRoutine() -> RoutineBlock? {
        if let running = routines.first(where: { isInProgress($0) }) {
            return running
        }
        if let upcoming = routines
            .filter({ isUpcoming($0) })
            .sorted(by: { startDate($0) ?? .distantFuture < startDate($1) ?? .distantFuture })
            .first {
            return upcoming
        }
        return routines.last
    }

    // now >= startTime AND now < endTime
    func isInProgress(_ routine: RoutineBlock) -> Bool {
        let startTimeInSeconds   = DateManager.shared.convertToSeconds(string: routine.startTime)
        let endTimeInSeconds   = DateManager.shared.convertToSeconds(string: routine.endTime)
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: now)
        return currentTimeInSeconds >= startTimeInSeconds && currentTimeInSeconds < endTimeInSeconds
    }

    // now < startTime
    func isUpcoming(_ routine: RoutineBlock) -> Bool {
        let startTimeInSeconds   = DateManager.shared.convertToSeconds(string: routine.startTime)
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: now)
        return currentTimeInSeconds < startTimeInSeconds
    }

    func startDate(_ routine: RoutineBlock) -> Date? {
        DateManager.shared.stringToDate(routine.startTime)
    }

    // MARK: Task states
    
    // completed  → now >= task endTime      (end time is in the past)
    // inProgress → now >= startTime AND now < endTime
    // upcoming   → now < startTime          (hasn't started yet)

    func updateTaskStates() {
        let currentTime = DateManager.shared.convertToSeconds(date: now)
        var updatedTasks = tasks
        
        for i in updatedTasks.indices {
            let start = DateManager.shared.convertToSeconds(string: updatedTasks[i].startTime)
            let end = start + CGFloat(updatedTasks[i].duration * 60)
            
            if currentTime >= end {
                updatedTasks[i].state = .completed
            } else if currentTime >= start && currentTime < end {
                updatedTasks[i].state = .inProgress
            } else {
                updatedTasks[i].state = .upcoming
            }
        }
        
        tasks = updatedTasks
    }

    func computeRoutineProgress() -> Double {
        guard let routine = activeRoutine else { return 0 }
        
        let now = DateManager.shared.convertToSeconds(date: now)
        let start = DateManager.shared.convertToSeconds(string: routine.startTime)
        let end   = DateManager.shared.convertToSeconds(string: routine.endTime)
        
        let total = end - start
        let elapsed = now - start
        
        guard total > 0 else { return 0 }
        return min(max(elapsed / total, 0), 1)
    }

    func computeCurrentTask() -> RoutineTask? {
        tasks.first { task in
            let now = DateManager.shared.convertToSeconds(date: now)
            let start = DateManager.shared.convertToSeconds(string: task.startTime)
            let end = start + CGFloat(task.duration * 60)
            return now >= start && now < end
        }
    }

    func recalculate() {
        now           = Date()
        activeRoutine = computeActiveRoutine()
        tasks         = activeRoutine?.tasks ?? tasks
        updateTaskStates()
        progress    = computeRoutineProgress()
        currentTask = computeCurrentTask()
        
        checkForCompletedRoutines()
    }
    
    // MARK: - Completion Sheet
    
    private func checkForCompletedRoutines() {
        guard !shouldShowCompletionSheet else { return }
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id else { return }
        
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: now)
        
        print("[DEBUG] checkForCompletedRoutines: routines count = \(routines.count), pending = \(pendingRoutineIds.count)")
        
        for routine in routines {
            guard !completedRoutineIds.contains(routine.id) else { continue }
            
            let endTimeInSeconds = DateManager.shared.convertToSeconds(string: routine.endTime)
            let hasEnded = currentTimeInSeconds >= endTimeInSeconds
            
            print("[DEBUG]   routine: \(routine.title), endTime: \(routine.endTime), now: \(currentTimeInSeconds), hasEnded: \(hasEnded)")
            
            guard hasEnded else { continue }
            
            let hasRecord = CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) != nil
            
            print("[DEBUG]     hasRecord: \(hasRecord)")
            
            if hasRecord {
                completedRoutineIds.insert(routine.id)
                continue
            }
            
            pendingRoutineIds.append(routine.id)
            print("[DEBUG]     Added to pendingRoutineIds")
        }
        
        print("[DEBUG] Final pendingRoutineIds: \(pendingRoutineIds)")
        
        if !pendingRoutineIds.isEmpty {
            shouldShowCompletionSheet = true
            print("[DEBUG] shouldShowCompletionSheet = true")
        }
    }
}
