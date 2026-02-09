//
//  Routine.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct Routine: Identifiable {
    let id: String
    var name: String
    var description: String
    var iconString: String
    var colorString: String
    var startTime: Date
    var endTime: Date
    var activities: [Activity]
}

extension Routine {
    
    // MARK: - 1. Morning Routine (The "Start Right" Routine)
    static let mockMorning = Routine(
        id: UUID().uuidString,
        name: "Morning Ritual",
        description: "Start the day with clarity and energy.",
        iconString: "sun.max.fill", // SF Symbol
        colorString: "#FFA500",     // Orange
        startTime: DateHelper.today(at: 7, min: 0),
        endTime: DateHelper.today(at: 8, min: 0),
        activities: [
        ]
    )

    // MARK: - 2. Work Routine (Deep Focus)
    static let mockWork = Routine(
        id: UUID().uuidString,
        name: "Deep Work Block",
        description: "High intensity focus time for coding.",
        iconString: "desktopcomputer",
        colorString: "#007AFF",     // Blue
        startTime: DateHelper.today(at: 9, min: 30),
        endTime: DateHelper.today(at: 12, min: 30),
        activities: [
        ]
    )

    // MARK: - 3. Evening Routine (Wind Down)
    static let mockEvening = Routine(
        id: "UUID().uuidString",
        name: "Night Wind Down",
        description: "Disconnect and prepare for sleep.",
        iconString: "moon.stars.fill",
        colorString: "#5856D6",     // Purple
        startTime: DateHelper.today(at: 21, min: 0),
        endTime: DateHelper.today(at: 22, min: 0),
        activities: [
        ]
    )
    
    // MARK: - 3. Evening Routine (Wind Down)
    static let updatedMockEvening = Routine(
        id: "UUID().uuidString",
        name: "Updated!!",
        description: "Disconnect and prepare for sleep.",
        iconString: "moon.stars.fill",
        colorString: "#5856D6",     // Purple
        startTime: DateHelper.today(at: 21, min: 0),
        endTime: DateHelper.today(at: 22, min: 0),
        activities: [
        ]
    )
    
    // Helper to group them all
    static let allMocks = [mockMorning, mockWork, mockEvening]
}

struct DateHelper {
    static func today(at hour: Int, min: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = min
        return calendar.date(from: components) ?? Date()
    }
}
