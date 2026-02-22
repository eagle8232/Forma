//
//  Routine.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct RoutineBlock: Identifiable {
    var id: String
    var title: String
    var description: String?
    var startTime: String
    var endTime: String
    var icon: String
    var accentColor: String
    var tasks: [RoutineTask]
    var intensity: BlockIntensity?
}

enum BlockIntensity: String, Codable {
    case low = "Low Peak"
    case medium = "Medium Peak"
    case high = "High Peak"
}

extension RoutineBlock {
    
    // MARK: - Mock Data
    
    // MARK: - 1. Morning Routine (The "Start Right" Routine)
    static let mockMorning = RoutineBlock(
        id: UUID().uuidString,
        title: "Morning Awakening",
        startTime: "06:00 AM",
        endTime: "08:00 AM",
        icon: "☀️",
        accentColor: "#F8C44F",
        tasks: [
            RoutineTask(
                id: UUID().uuidString,
                title: "Hydrate & Light Exposure",
                duration: "15 mins",
                description: "Living Room",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Mindfulness Meditation",
                duration: "10 mins",
                description: "Bedroom",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Cold Shower",
                duration: "5 mins",
                description: "Bathroom",
                isCompleted: false
            )
        ],
        intensity: .low
    )
    
    // MARK: - 2. Work Routine (Deep Focus)
    static let mockWork = RoutineBlock(
        id: UUID().uuidString,
        title: "Deep Work Flow",
        startTime: "09:00 AM",
        endTime: "12:00 PM",
        icon: "🧠",
        accentColor: "#4F9EF8",
        tasks: [
            RoutineTask(
                id: UUID().uuidString,
                title: "Deep Focus Block 1",
                duration: "90 mins",
                description: "Office",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Review Strategy Docs",
                duration: "45 mins",
                description: "Office",
                isCompleted: false
            )
        ],
        intensity: .high
    )
    
    // MARK: - 3. Evening Routine (Wind Down)
    static let mockEvening = RoutineBlock(
        id: UUID().uuidString,
        title: "Evening Wind-Down",
        startTime: "08:00 PM",
        endTime: "10:00 PM",
        icon: "🌙",
        accentColor: "#9B7FE8",
        tasks: [
            RoutineTask(
                id: UUID().uuidString,
                title: "Digital Detox",
                duration: "All Devices Off",
                description: "",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Reflective Journaling",
                duration: "20 mins",
                description: "Study",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Prepare for Tomorrow",
                duration: "10 mins",
                description: "Bedroom",
                isCompleted: false
            )
        ],
        intensity: .medium
    )
    
    // MARK: - 4. Updated Evening (For Testing Updates)
    static let updatedMockEvening = RoutineBlock(
        id: mockEvening.id,
        title: "Updated Wind-Down",
        startTime: "08:30 PM",
        endTime: "10:30 PM",
        icon: "🌙",
        accentColor: "#9B7FE8",
        tasks: [
            RoutineTask(
                id: UUID().uuidString,
                title: "Digital Detox",
                duration: "All Devices Off",
                description: "",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Updated Journaling Practice",
                duration: "25 mins",
                description: "Study",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Prepare for Tomorrow",
                duration: "10 mins",
                description: "Bedroom",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Light Stretching", // ✅ New task
                duration: "10 mins",
                description: "Living Room",
                isCompleted: false
            )
        ],
        intensity: nil
    )
    
    // MARK: - All Mocks Array
    static let allMocks: [RoutineBlock] = [
        mockMorning,
        mockWork,
        mockEvening
    ]
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
