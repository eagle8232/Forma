//
//  Goal.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

// MARK: - Goal Model

struct Goal: Identifiable, Codable {
    let id:          String
    var title:       String
    var description: String
    var accentColor: String       // hex string
    var routineId:   String?      // linked routine id
    var durationDays: Int?        // nil = forever
    var startDate:   Date
    var completedDays: [Date]     // days user completed the linked routine

    // MARK: - Computed

    var progress: Double {
        guard let duration = durationDays, duration > 0 else {
            // Forever goal — show last 30 days completion rate
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let recent = completedDays.filter { $0 >= cutoff }
            return min(Double(recent.count) / 30.0, 1.0)
        }
        return min(Double(completedDays.count) / Double(duration), 1.0)
    }

    var streak: Int {
        var count = 0
        var date  = Calendar.current.startOfDay(for: Date())
        let cal   = Calendar.current

        while true {
            let completed = completedDays.contains {
                cal.isDate($0, inSameDayAs: date)
            }
            if completed {
                count += 1
                date = cal.date(byAdding: .day, value: -1, to: date) ?? date
            } else {
                break
            }
        }
        return count
    }

    var daysCompleted: Int { completedDays.count }

    var daysRemaining: Int? {
        guard let duration = durationDays else { return nil }
        let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(duration - elapsed, 0)
    }

    var isAchieved: Bool {
        guard let duration = durationDays else { return false }
        return completedDays.count >= duration
    }

    var accent: Color {
        Color(uiColor: UIColor(hex: accentColor))
    }
}

// MARK: - Mock

extension Goal {
    static var mocks: [Goal] {
        [
            Goal(
                id: UUID().uuidString,
                title: "Morning Productivity",
                description: "Complete the morning routine before 9am",
                accentColor: "#8B5CF6",
                routineId: nil,
                durationDays: 30,
                startDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
                completedDays: (0..<17).compactMap {
                    Calendar.current.date(byAdding: .day, value: -$0, to: Date())
                }
            ),
            Goal(
                id: UUID().uuidString,
                title: "Learn Swift",
                description: "1 hour daily coding session",
                accentColor: "#10B981",
                routineId: nil,
                durationDays: 90,
                startDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
                completedDays: (0..<45).compactMap {
                    Calendar.current.date(byAdding: .day, value: -$0, to: Date())
                }
            ),
            Goal(
                id: UUID().uuidString,
                title: "Deep Work Habit",
                description: "3 hours of focused work daily",
                accentColor: "#F59E0B",
                routineId: nil,
                durationDays: 30,
                startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                completedDays: (0..<3).compactMap {
                    Calendar.current.date(byAdding: .day, value: -$0, to: Date())
                }
            ),
        ]
    }

    static var achievedMock: Goal {
        Goal(
            id: UUID().uuidString,
            title: "Read 12 Books",
            description: "Read one book per month",
            accentColor: "#6B7280",
            routineId: nil,
            durationDays: 365,
            startDate: Calendar.current.date(byAdding: .year, value: -1, to: Date())!,
            completedDays: (0..<365).compactMap {
                Calendar.current.date(byAdding: .day, value: -$0, to: Date())
            }
        )
    }
}
