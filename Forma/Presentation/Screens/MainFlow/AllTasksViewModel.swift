//
//  AllTasksViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/19/26.
//

import SwiftUI
import Combine

@MainActor
final class AllTasksViewModel: ObservableObject {

    // MARK: - Published

    @Published var completedTasks: [RoutineTask] = []
    @Published var activeTasks:    [RoutineTask] = []
    @Published var upcomingTasks:  [RoutineTask] = []
    @Published var now: Date = Date()

    // MARK: - Input

    let routine: RoutineBlock
    let tasks:   [RoutineTask]

    // MARK: - Computed

    var routineProgress: Double {
        let current = DateManager.shared.convertToSeconds(date: now)
        let start   = DateManager.shared.convertToSeconds(string: routine.startTime)
        let end     = DateManager.shared.convertToSeconds(string: routine.endTime)
        let total   = end - start
        guard total > 0 else { return 0 }
        return min(max(Double(current - start) / Double(total), 0), 1)
    }

    var routineSummary: String {
        let done     = completedTasks.count
        let active   = activeTasks.count
        let upcoming = upcomingTasks.count
        let end      = routine.endTime
        var parts: [String] = []
        if done > 0     { parts.append("\(done) done") }
        if active > 0   { parts.append("\(active) active") }
        if upcoming > 0 { parts.append("\(upcoming) upcoming") }
        parts.append("ends \(end)")
        return parts.joined(separator: " · ")
    }

    var accent: Color {
        Color(uiColor: UIColor(hex: routine.accentColor))
    }

    // MARK: - Init

    init(routine: RoutineBlock, tasks: [RoutineTask]) {
        self.routine = routine
        self.tasks   = tasks
        refresh()
    }

    // MARK: - Refresh

    func refresh() {
        now = Date()
        let uniqueTasks = removeDuplicates(from: tasks)
        completedTasks = uniqueTasks.filter { $0.state == .completed }.sorted { time($0) < time($1) }
        activeTasks    = uniqueTasks.filter { $0.state == .inProgress }.sorted { time($0) < time($1) }
        upcomingTasks  = uniqueTasks.filter { $0.state == .upcoming }.sorted { time($0) < time($1) }
    }
    
    private func time(_ task: RoutineTask) -> CGFloat {
        DateManager.shared.convertToSeconds(string: task.startTime)
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

    // MARK: - Minutes remaining for a task

    func minutesRemaining(for task: RoutineTask) -> Int {
        let current = DateManager.shared.convertToSeconds(date: now)
        let start   = DateManager.shared.convertToSeconds(string: task.startTime)
        let end     = start + CGFloat(task.duration * 60)
        let rem     = max(end - current, 0)
        return Int(ceil(Double(rem) / 60.0))
    }

    // MARK: - Progress for active task

    func taskProgress(for task: RoutineTask) -> Double {
        let current = DateManager.shared.convertToSeconds(date: now)
        let start   = DateManager.shared.convertToSeconds(string: task.startTime)
        let end     = start + CGFloat(task.duration * 60)
        let total   = end - start
        guard total > 0 else { return 0 }
        return min(max(Double(current - start) / Double(total), 0), 1)
    }
}
