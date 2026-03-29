//
//  GoalsDetailsViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI
import Combine

// MARK: - GoalDetailViewModel

@MainActor
final class GoalDetailViewModel: ObservableObject {

    // MARK: - Published

    @Published var goal: Goal
    @Published var linkedRoutine: RoutineBlock? = nil

    // MARK: - Init

    init(goal: Goal) {
        self.goal = goal
        loadLinkedRoutine()
    }

    // MARK: - Computed

    var accent: Color { goal.accent }

    var progressText: String { "\(Int(goal.progress * 100))%" }

    var daysCompletedText: String {
        guard let duration = goal.durationDays else {
            return "\(goal.daysCompleted) days completed"
        }
        return "\(goal.daysCompleted) of \(duration) days"
    }

    var daysRemainingText: String? {
        guard let rem = goal.daysRemaining else { return nil }
        return rem == 0 ? "Last day" : "\(rem) days left"
    }

    var streakText: String { "\(goal.streak)" }
    var bestStreak: Int { goal.streak } // replace with persisted best

    // MARK: - This week days (Mon–Sun)

    var weekEntries: [WeekEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Find Monday of current week
        var comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        comps.weekday = 2 // Monday
        let monday = cal.date(from: comps) ?? today

        return (0..<7).map { offset in
            let date    = cal.date(byAdding: .day, value: offset, to: monday) ?? monday
            let isToday = cal.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            let done    = goal.completedDays.contains { cal.isDate($0, inSameDayAs: date) }

            let label   = ["M","T","W","T","F","S","S"][offset]

            let state: WeekEntry.State = isFuture ? .future
                                       : done      ? .completed
                                       :             .missed

            return WeekEntry(label: label, date: date, state: state, isToday: isToday)
        }
    }

    struct WeekEntry: Identifiable {
        let id    = UUID()
        let label: String
        let date:  Date
        let state: State
        let isToday: Bool

        enum State { case completed, missed, future }
    }

    // MARK: - Stats

    var statsItems: [(String, String)] {
        var items: [(String, String)] = []
        items.append(("\(goal.streak)", "Streak"))
        items.append(("\(bestStreak)", "Best"))
        items.append(("\(goal.daysCompleted > 0 ? goal.daysCompleted : 0)", "Completed"))
        if let rem = goal.daysRemaining {
            items.append(("\(rem)", "Days left"))
        } else {
            items.append(("∞", "Duration"))
        }
        return items
    }

    // MARK: - Load linked routine

    private func loadLinkedRoutine() {
        guard let routineId = goal.routineId else { return }
        // Replace with actual fetch from DependencyContainer or Firestore
        let allRoutines = DependencyContainer.shared.routines ?? []
        linkedRoutine = allRoutines.first { $0.id == routineId }
    }

    // MARK: - Delete

    func delete(completion: @escaping () -> Void) {
        // Firestore delete
        completion()
    }
}
