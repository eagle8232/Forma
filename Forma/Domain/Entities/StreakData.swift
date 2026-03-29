//
//  StreakData.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import Foundation

struct StreakData {
    let currentStreak: Int
    let bestStreak:    Int
    let totalDays:     Int
    let completionRate: Double       // 0.0 – 1.0
    let weekDays:      [DayEntry]    // 7 entries, Mon–Sun

    struct DayEntry {
        let label:      String       // "M", "T" etc.
        let state:      DayState
        let completion: Double       // 0.0 – 1.0

        enum DayState {
            case completed
            case partial
            case missed
            case future
            case today
        }
    }

    var thisWeekCompleted: Int {
        weekDays.filter { $0.state == .completed || $0.state == .today }.count
    }
}

// Mock Data

extension StreakData {
    static var mock: StreakData {
        StreakData(
            currentStreak: 12,
            bestStreak:    18,
            totalDays:     24,
            completionRate: 0.86,
            weekDays: [
                .init(label: "M", state: .completed, completion: 1.0),
                .init(label: "T", state: .completed, completion: 0.9),
                .init(label: "W", state: .completed, completion: 1.0),
                .init(label: "T", state: .missed,    completion: 0.0),
                .init(label: "F", state: .completed, completion: 1.0),
                .init(label: "S", state: .partial,   completion: 0.6),
                .init(label: "S", state: .today,     completion: 0.75),
            ]
        )
    }
}
