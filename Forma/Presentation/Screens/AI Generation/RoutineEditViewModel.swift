//
//  RoutineEditViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/22/26.
//

import Foundation
import Combine

final class RoutineEditViewModel {

    // MARK: - State
    @Published var routine: RoutineBlock

    init(routine: RoutineBlock) {
        self.routine = routine
    }

    // MARK: - Validation

    var totalTaskMinutes: Int {
        routine.tasks.reduce(0) { $0 + Int($1.duration) }
    }

    var routineWindowMinutes: Int {
        guard
            let start = timeDate(from: routine.startTime),
            let end   = timeDate(from: routine.endTime)
        else { return 0 }
        return Int(max(end.timeIntervalSince(start) / 60, 0))
    }

    var isDurationValid: Bool {
        totalTaskMinutes == routineWindowMinutes
    }

    // MARK: - Save

    func buildUpdatedRoutine(
        title: String,
        description: String,
        icon: String,
        startDate: Date,
        endDate: Date,
        tasks: [RoutineTask]
    ) -> RoutineBlock {
        var updated        = routine
        updated.title       = title
        updated.description = description
        updated.icon        = icon
        updated.startTime   = timeString(from: startDate)
        updated.endTime     = timeString(from: endDate)
        updated.tasks       = tasks
        return updated
    }

    // MARK: - Helpers

    func parseDuration(_ string: String) -> Int {
        let parts = string.lowercased().components(separatedBy: " ")
        var total = 0, i = 0
        while i < parts.count {
            if let value = Int(parts[i]) {
                let unit = i + 1 < parts.count ? parts[i + 1] : ""
                if unit.hasPrefix("hr") || unit.hasPrefix("hour") { total += value * 60 }
                else if unit.hasPrefix("min") { total += value }
                i += 2
            } else { i += 1 }
        }
        return total
    }

    // MARK: - Helpers

    func timeDate(from string: String) -> Date? {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.date(from: string)
    }

    func timeString(from date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    func defaultTime(hour: Int, minute: Int) -> Date {
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour; c.minute = minute
        return Calendar.current.date(from: c) ?? Date()
    }
}
