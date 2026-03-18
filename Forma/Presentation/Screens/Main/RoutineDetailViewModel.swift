//
//  RoutineDetailViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/15/26.
//

import Foundation
import SwiftUI

@MainActor
class RoutineDetailViewModel: ObservableObject {
    @Published var tasks: [RoutineTask] {
        didSet {
            detectChanges()
            validateDurations()
        }
    }
    @Published var routine: RoutineBlock {
        didSet {
            detectChanges()
            validateDurations()
        }
    }

    @Published var expandedTaskID: String?  = nil
    @Published var appeared                 = false
    @Published var isSaveButtonDisabled     = true
    @Published var showSuccessAlert         = false
    @Published var showErrorAlert           = false
    @Published var validationErrorMessage   = ""
    @Published var isTitleFocused: Bool     = false
    @Published var draggingTaskID:  String? = nil
    @Published var draggingTargetID: String? = nil
    @Published var durationMismatch: DurationMismatch? = nil

    // MARK: - Snapshots
    private let originalRoutine: RoutineBlock
    private let originalTasks:   [RoutineTask]

    // MARK: - Computed
    var isValid: Bool { durationMismatch == nil && !routine.title.trimmingCharacters(in: .whitespaces).isEmpty && !tasks.isEmpty }
    var accent:  Color { Color(uiColor: UIColor(hex: routine.accentColor)) }

    // MARK: - Init
    init(routine: RoutineBlock) {
        self.routine         = routine
        self.tasks           = routine.tasks
        self.originalRoutine = routine
        self.originalTasks   = routine.tasks
    }

    // MARK: - Duration Validation

    /// Calculates whether the sum of task durations equals the routine window.
    /// Updates `durationMismatch` — nil means balanced, non-nil shows the banner.
    func validateDurations() {
        let routineSeconds = DateManager.shared.convertToSeconds(routine.endTime)
                           - DateManager.shared.convertToSeconds(routine.startTime)
        let tasksSeconds   = CGFloat(tasks.reduce(0) { $0 + $1.duration * 60 })

        guard routineSeconds != tasksSeconds else {
            durationMismatch = nil
            return
        }

        durationMismatch = DurationMismatch(
            tasksTotalFormatted:   formatDuration(Int(tasksSeconds)),
            routineWindowFormatted: formatDuration(Int(routineSeconds)),
            delta: Int(routineSeconds - CGFloat(tasksSeconds))
        )
    }

    private func formatDuration(_ totalSeconds: Int) -> String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0           { return "\(h)h" }
        return "\(m)m"
    }

    // MARK: - Change Detection
    func detectChanges() {
        let routineChanged = routine.title       != originalRoutine.title
                          || routine.startTime   != originalRoutine.startTime
                          || routine.endTime     != originalRoutine.endTime
                          || routine.accentColor != originalRoutine.accentColor
                          || routine.icon        != originalRoutine.icon

        let tasksChanged = tasks.count != originalTasks.count
                        || zip(tasks, originalTasks).contains { cur, orig in
                               cur.id          != orig.id          ||
                               cur.title       != orig.title       ||
                               cur.description != orig.description ||
                               cur.startTime   != orig.startTime   ||
                               cur.duration    != orig.duration
                           }

        isSaveButtonDisabled = !(routineChanged || tasksChanged)
    }

    // MARK: - Validation message (for save error alert)
    var validationError: String {
        if routine.title.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Routine title cannot be empty."
        }
        if tasks.isEmpty {
            return "Add at least one task before saving."
        }
        if tasks.contains(where: { $0.title.trimmingCharacters(in: .whitespaces).isEmpty }) {
            return "All tasks must have a title."
        }
        if let mismatch = durationMismatch {
            return mismatch.message
        }
        return "Please fix the errors before saving."
    }

    // MARK: - Appear
    func triggerAppear() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.78)) {
            appeared = true
        }
    }

}

// MARK: - Tasks Actions

extension RoutineDetailViewModel {
    func expand(_ task: RoutineTask) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            expandedTaskID = expandedTaskID == task.id ? nil : task.id
        }
    }

    func deleteTask(id: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            tasks.removeAll { $0.id == id }
            expandedTaskID = nil
        }
    }

    func updateTask(id: String, title: String, description: String) {
        guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }
        var updated         = tasks[i]
        updated.title       = title.isEmpty ? tasks[i].title : title
        updated.description = description
        tasks[i]            = updated
        routine.tasks       = tasks

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            expandedTaskID = nil
        }
    }

    func addTask() {
        let task = RoutineTask(
            id: UUID().uuidString,
            title: "New task",
            startTime: routine.endTime,
            duration: 30,
            description: ""
        )
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            tasks.append(task)
            expandedTaskID = task.id
        }
    }

    // - Reorder
    func moveTasks(from source: IndexSet, to destination: Int) {
        let timeSlots = tasks.map { (startTime: $0.startTime, duration: $0.duration) }
        tasks.move(fromOffsets: source, toOffset: destination)
        for i in tasks.indices {
            tasks[i].startTime = timeSlots[i].startTime
            tasks[i].duration  = timeSlots[i].duration
        }
        routine.tasks = tasks
        recalculateStartTimes()
    }

    private func recalculateStartTimes() {
        guard !tasks.isEmpty else { return }
        tasks[0].startTime = routine.startTime
        for i in 1..<tasks.count {
            tasks[i].startTime = endTime(of: tasks[i - 1])
        }
    }
    
    func updateTaskDuration(id: String, minutes: Int) {
        guard let i = tasks.firstIndex(where: { $0.id == id }) else { return }
        guard minutes > 0 else { return }   // - Never allow zero or negative

        tasks[i].duration = minutes
        routine.tasks = tasks

        recalculateStartTimes(from: i)
    }

    /// Recalculates start times from a given index downward.
    /// Passing index 0 rebuilds the entire chain.
    func recalculateStartTimes(from startIndex: Int = 0) {
        guard !tasks.isEmpty else { return }

        for i in startIndex..<tasks.count where i > 0 {
            tasks[i].startTime = endTime(of: tasks[i - 1])
        }
    }

    private func endTime(of task: RoutineTask) -> String {
        guard let startDate = DateManager.shared.parseDate(task.startTime) else {
            return task.startTime
        }
        let endDate = startDate.addingTimeInterval(TimeInterval(task.duration * 60))
        return DateManager.shared.formatTime(endDate)
    }
}

// MARK: - Date Helpers

extension RoutineDetailViewModel {
    func formatTime(_ raw: String) -> String {
        let isoFull = ISO8601DateFormatter()
        isoFull.formatOptions = [.withInternetDateTime, .withSpaceBetweenDateAndTime]
        if let d = isoFull.date(from: raw) {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d)
        }
        let isoBasic = ISO8601DateFormatter()
        if let d = isoBasic.date(from: raw) {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: d)
        }
        let parts = raw.split(separator: ":").map(String.init)
        if parts.count >= 2 { return "\(parts[0]):\(parts[1])" }
        return raw
    }
}

