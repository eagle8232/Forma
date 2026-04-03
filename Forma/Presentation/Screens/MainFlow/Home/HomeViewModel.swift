//
//  HomeViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/25/26.
//

import SwiftUI
import Combine
import FirebaseAuth
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

    // MARK: - Private

    private var timer: AnyCancellable?
    private let initialRoutines: [RoutineBlock]?

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

    // MARK: - Load

    func load() async {
        loadState = .loading
        
        if let preloaded = initialRoutines, !preloaded.isEmpty {
            routines = preloaded.sorted { $0.startTime < $1.startTime }
        } else {
            routines = (DependencyContainer.shared.routines ?? []).sorted { $0.startTime < $1.startTime }
        }
        
        if let containerUser = DependencyContainer.shared.currentUser {
            user = containerUser
        }
        
        activeRoutine = computeActiveRoutine()
        tasks         = activeRoutine?.tasks ?? []
        recalculate()
        loadState = .loaded
        
        requestNotificationPermissionIfNeeded()
        scheduleNotificationsForRoutines()
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
        let now = DateManager.shared.convertToSeconds(date: now)
        for i in tasks.indices {
            let start = DateManager.shared.convertToSeconds(string: tasks[i].startTime)
            let end = start + CGFloat(tasks[i].duration * 60)
            
            if now >= end {
                tasks[i].state = .completed
            } else if now >= start && now < end {
                tasks[i].state = .inProgress
            } else {
                tasks[i].state = .upcoming
            }
        }
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
    }
}
