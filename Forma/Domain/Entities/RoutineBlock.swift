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
        title: "Morning Routine",
        startTime: "06:00",
        endTime: "09:00",
        icon: "☀️",
        accentColor: "#F8C44F",
        tasks: [
            RoutineTask(
                id: UUID().uuidString,
                title: "Hydrate & Light Stretching",
                duration: "15 mins",
                description: "Living Room",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Morning Workout",
                duration: "30 mins",
                description: "Home Gym / Outdoors",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Shower & Get Dressed",
                duration: "20 mins",
                description: "Bathroom",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Make Bed & Tidy Up",
                duration: "15 mins",
                description: "Bedroom",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Prepare & Eat Breakfast",
                duration: "30 mins",
                description: "Kitchen",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Brush Teeth & Skincare",
                duration: "15 mins",
                description: "Bathroom",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Morning Commute / Walk",
                duration: "30 mins",
                description: "Outdoors",
                isCompleted: false
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Coffee & Review Daily Goals",
                duration: "25 mins",
                description: "Workspace",
                isCompleted: false
            )
        ],
        intensity: .medium
    )
    
    // MARK: - 2. Work Routine (Deep Focus)
        static let mockWork = RoutineBlock(
            id: UUID().uuidString,
            title: "Work Flow",
            startTime: "09:10",
            endTime: "17:00",
            icon: "🧠",
            accentColor: "#4F9EF8",
            tasks: [
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Standup & Email Triage",
                    duration: "30 mins",
                    description: "Desk",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Deep Focus: iOS Feature Dev",
                    duration: "90 mins",
                    description: "Xcode",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Code Review & PRs",
                    duration: "45 mins",
                    description: "GitHub",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Lunch & Screen Break",
                    duration: "60 mins",
                    description: "Kitchen / Outdoors",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Deep Focus: Refactoring",
                    duration: "90 mins",
                    description: "Xcode",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Team Sync / Planning",
                    duration: "45 mins",
                    description: "Meeting Room",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Architecture & UI Review",
                    duration: "60 mins",
                    description: "Desk",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Documentation & Wrap Up",
                    duration: "50 mins",
                    description: "Notion / Jira",
                    isCompleted: false
                )
            ],
            intensity: .high
        )
        
        // MARK: - 3. Evening Routine (Wind Down)
        static let mockEvening = RoutineBlock(
            id: UUID().uuidString,
            title: "Evening Routine",
            startTime: "17:10",
            endTime: "21:00",
            icon: "🌙",
            accentColor: "#9B7FE8",
            tasks: [
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Disconnect & Relax",
                    duration: "40 mins",
                    description: "Living Room",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Cook & Eat Dinner",
                    duration: "60 mins",
                    description: "Kitchen",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Side Income / Micro-SaaS Work",
                    duration: "60 mins",
                    description: "Home Office",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Arabic Vocabulary & Reading",
                    duration: "45 mins",
                    description: "Study Desk",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Hobby Research (Cars / Forums)",
                    duration: "25 mins",
                    description: "Sofa",
                    isCompleted: false
                )
            ],
            intensity: .medium
        )
        
        // MARK: - 4. Sleep Routine (Wind Down)
        static let mockSleep = RoutineBlock(
            id: UUID().uuidString,
            title: "Sleep Routine",
            startTime: "21:10",
            endTime: "22:30",
            icon: "💤",
            accentColor: "#5E5CE6",
            tasks: [
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Digital Detox & Dim Lights",
                    duration: "15 mins",
                    description: "Bedroom",
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
                    duration: "15 mins",
                    description: "Bedroom",
                    isCompleted: false
                ),
                RoutineTask(
                    id: UUID().uuidString,
                    title: "Reading",
                    duration: "30 mins",
                    description: "Bed",
                    isCompleted: false
                )
            ],
            intensity: .low
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
                title: "Light Stretching",
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
        mockEvening,
        mockSleep
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
