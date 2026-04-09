//
//  ProfileViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isSigningOut: Bool = false
    @Published var signOutError: String? = nil
    @Published var showSignOutConfirm: Bool = false
    @Published var showDeleteConfirm: Bool = false
    @Published var isDeleting: Bool = false
    @Published var deleteError: String? = nil
    
    @Published var todayScore: Int = 0
    @Published var todayCompletedRoutines: Int = 0
    @Published var totalRoutines: Int = 0
    @Published var streak: Int = 0
    @Published var weeklyCompletionRate: Int = 0
    @Published var monthlyHours: Double = 0
    @Published var weeklyData: [WeekBarData] = []
    
    @Published var showWakeTimePicker: Bool = false
    @Published var showSleepTimePicker: Bool = false
    @Published var showWorkStylePicker: Bool = false
    @Published var showGoalsPicker: Bool = false
    
    var editingWakeTime: Date {
        get { user.preferences?.wakeUpTime ?? Date() }
        set { updateWakeTime(newValue) }
    }
    
    var editingSleepTime: Date {
        get { user.preferences?.sleepTime ?? Date() }
        set { updateSleepTime(newValue) }
    }

    // MARK: - Dependencies

    var user: User
    private let authRepository: AuthRepositoryProtocol

    // MARK: - Init

    init(user: User, authRepository: AuthRepositoryProtocol) {
        self.user = user
        self.authRepository = authRepository
    }

    // MARK: - Computed: Credentials

    var displayName: String {
        let full = user.credentials.name
        let parts = full.split(separator: " ")
        guard parts.count >= 2 else { return full }
        return full
    }

    var firstName: String {
        user.credentials.name.split(separator: " ").first.map(String.init) ?? user.credentials.name
    }

    var lastName: String {
        let parts = user.credentials.name.split(separator: " ")
        guard parts.count >= 2 else { return "" }
        return parts.dropFirst().joined(separator: " ")
    }

    var email: String { user.credentials.email }
    var isAnonymous: Bool { user.credentials.isAnonymous }

    // MARK: - Computed: Preferences

    var profession: String {
        user.preferences?.profession ?? "—"
    }

    var wakeUpFormatted: String {
        guard let prefs = user.preferences else { return "—" }
        return formatTime(prefs.wakeUpTime)
    }

    var sleepFormatted: String {
        guard let prefs = user.preferences else { return "—" }
        return formatTime(prefs.sleepTime)
    }

    var focusTimeFormatted: String {
        guard let focus = user.preferences?.focusTime else { return "—" }
        return formatTime(focus)
    }

    var goalsFormatted: String {
        user.preferences?.goal.joined(separator: " · ") ?? "—"
    }
    
    var additionalContextFormatted: String? {
        guard let context = user.preferences?.additionalContext, !context.isEmpty else { return nil }
        let formatted = context
            .replacingOccurrences(of: ":", with: ": ")
            .replacingOccurrences(of: ". ", with: " · ")
        return formatted
    }

    var workStyle: String? {
        user.preferences?.workStyle
    }

    var timezone: String {
        user.preferences?.resolvedTimezone ?? TimeZone.current.identifier
    }

    var location: String {
        TimeZone.current.identifier
            .split(separator: "/")
            .last
            .map { String($0).replacingOccurrences(of: "_", with: " ") }
            ?? timezone
    }
    
    // MARK: - Stats
    
    func loadStats() {
        todayScore = CompletionService.shared.getTodayScore()
        streak = CompletionService.shared.getStreak()
        
        let userId = user.credentials.id
        let completedRoutines = CompletionService.shared.getTodayCompletedRoutinesCount(userId: userId)
        todayCompletedRoutines = completedRoutines
        totalRoutines = DependencyContainer.shared.routines?.count ?? 0
        
        let weeklyStats = CompletionService.shared.getWeeklyStats()
        let totalRoutines = DependencyContainer.shared.routines?.count ?? 1
        weeklyCompletionRate = totalRoutines > 0 ? (weeklyStats.completedRoutines * 100 / totalRoutines) : 0
        
        let monthlyStats = CompletionService.shared.getMonthlyStats()
        monthlyHours = monthlyStats.hours
        
        loadWeeklyData()
    }
    
    private func loadWeeklyData() {
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
        
        var data: [WeekBarData] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: weekStart) else { continue }
            
            let weekday = calendar.component(.weekday, from: date)
            let label = weekdayLabels[weekday] ?? "M"
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today
            
            let stats = CompletionService.shared.getStats(for: date)
            let pct = stats.score > 0 ? Double(stats.score) / 100.0 : 0.0
            
            let state: WeekBarData.State = isToday ? .today : (isFuture ? .upcoming : .done)
            
            data.append(WeekBarData(day: label, pct: pct, state: state))
        }
        
        weeklyData = data
    }

    // MARK: - Actions

    func signOut(onComplete: @escaping () -> Void) {
        Task {
            isSigningOut = true
            do {
                try await authRepository.signOut()
                onComplete()
            } catch {
                signOutError = error.localizedDescription
                isSigningOut = false
            }
        }
    }
    
    func deleteAccount(onComplete: @escaping () -> Void) {
        Task {
            isDeleting = true
            deleteError = nil
            
            do {
                let userId = user.credentials.id
                
                let userRepo = UserRepository()
                let routineRepo = RoutineRepository()
                let completionRepo = CompletionRepository()
                
                try await routineRepo.deleteAllRoutines(userId: userId)
                
                try await completionRepo.deleteCompletionRecords(userId: userId)
                
                try await userRepo.deleteUser(user)
                
                try await authRepository.deleteUser()
                
                CoreDataManager.shared.deleteAllRoutines(forUserId: userId)
                CoreDataManager.shared.deleteUser(byId: userId)
                
                DependencyContainer.shared.clearSession()
                DependencyContainer.shared.clearOnboardingCompletion()
                
                onComplete()
            } catch {
                deleteError = error.localizedDescription
                isDeleting = false
            }
        }
    }
    
    func updateWakeTime(_ time: Date) {
        guard var preferences = user.preferences else { return }
        preferences.wakeUpTime = time
        user.preferences = preferences
        savePreferences()
    }
    
    func updateSleepTime(_ time: Date) {
        guard var preferences = user.preferences else { return }
        preferences.sleepTime = time
        user.preferences = preferences
        savePreferences()
    }
    
    func updateWorkStyle(_ style: String) {
        guard var preferences = user.preferences else { return }
        preferences.workStyle = style
        user.preferences = preferences
        savePreferences()
    }
    
    func updateGoals(_ goals: [String]) {
        guard var preferences = user.preferences else { return }
        preferences.goal = goals
        user.preferences = preferences
        savePreferences()
    }
    
    func updateAppearanceMode(_ mode: AppearanceMode) {
        guard var preferences = user.preferences else { return }
        preferences.appearanceMode = mode.rawValue
        user.preferences = preferences
        savePreferences()
    }
    
    private func savePreferences() {
        guard let updatedUser = user as User? else { return }
        
        CoreDataManager.shared.saveUser(updatedUser)
        
        DependencyContainer.shared.updateUser(updatedUser)
        
        Task {
            let userRepo = UserRepository()
            try? await userRepo.saveUser(updatedUser)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
