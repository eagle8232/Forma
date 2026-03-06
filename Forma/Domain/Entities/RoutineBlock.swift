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
                startTime: "06:00",
                duration: 900,
                description: "Drink some water and complete light stretching exercises inside the living room.",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Morning Workout",
                startTime: "06:15",
                duration: 1800,
                description: "Complete a highly effective morning workout routine to boost your daily energy!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Shower & Get Dressed",
                startTime: "06:45",
                duration: 1200,
                description: "Take a quick morning shower, then get properly dressed for the busy upcoming day",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Make Bed & Tidy Up",
                startTime: "07:05",
                duration: 900,
                description: "Make your bed quickly and tidy up the entire bedroom to maintain a clean space!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Prepare & Eat Breakfast",
                startTime: "07:20",
                duration: 1800,
                description: "Prepare a healthy breakfast in the kitchen and enjoy eating it before you leave.",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Brush Teeth & Skincare",
                startTime: "07:50",
                duration: 900,
                description: "Thoroughly brush your teeth and complete your daily skincare routine in bathroom",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Morning Commute / Walk",
                startTime: "08:05",
                duration: 1800,
                description: "Enjoy a refreshing morning walk outdoors to clear your mind before work begins!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Coffee & Review Daily Goals",
                startTime: "08:35",
                duration: 1500,
                description: "Drink morning coffee while reviewing your daily goals at your own home workspace",
                
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
                startTime: "09:10",
                duration: 1800,
                description: "Attend the daily standup meeting and quickly triage your unread morning emails!!",
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Deep Focus: iOS Feature Dev",
                startTime: "09:40",
                duration: 5400,
                description: "Engage in deep focus mode to develop and implement the brand new iOS features!!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Code Review & PRs",
                startTime: "11:10",
                duration: 2700,
                description: "Review pending pull requests on GitHub and provide valuable feedback to the team",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Lunch & Screen Break",
                startTime: "11:55",
                duration: 3600,
                description: "Take a well-deserved screen break and enjoy a nutritious lunch in the kitchen!!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Deep Focus: Refactoring",
                startTime: "12:55",
                duration: 5400,
                description: "Focus deeply on refactoring the legacy codebase to significantly improve speed!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Team Sync / Planning",
                startTime: "14:25",
                duration: 2700,
                description: "Participate in the team sync meeting to plan the upcoming sprint deliverables!!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Architecture & UI Review",
                startTime: "15:10",
                duration: 3600,
                description: "Carefully review the software architecture and the user interface design drafts.",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Documentation & Wrap Up",
                startTime: "16:10",
                duration: 3000,
                description: "Update the project documentation on Notion and wrap up all your tasks for today.",
                
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
                startTime: "17:10",
                duration: 2400,
                description: "Completely disconnect from your digital devices and relax in the living room....",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Cook & Eat Dinner",
                startTime: "17:50",
                duration: 3600,
                description: "Cook a delicious and healthy dinner in the kitchen, then enjoy eating your meal.",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Side Income / Micro-SaaS Work",
                startTime: "18:50",
                duration: 3600,
                description: "Spend dedicated time working on your side income projects and micro-SaaS apps!!!",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Arabic Vocabulary & Reading",
                startTime: "19:50",
                duration: 2700,
                description: "Practice your Arabic vocabulary and spend some time reading an interesting book.",
                
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Hobby Research (Cars / Forums)",
                startTime: "20:35",
                duration: 1500,
                description: "Research your favorite hobbies, browse car forums, and unwind on the cozy sofa.",
                
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
                startTime: "21:10",
                duration: 900,
                description: "Start a digital detox, dim the bedroom lights, and prepare for a restful sleep!!",
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Reflective Journaling",
                startTime: "21:25",
                duration: 1200,
                description: "Write down your thoughts and reflect on the day by journaling in your study room",
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Prepare for Tomorrow",
                startTime: "21:45",
                duration: 900,
                description: "Prepare your clothes and belongings in the bedroom for a smooth morning tomorrow",
            ),
            RoutineTask(
                id: UUID().uuidString,
                title: "Reading",
                startTime: "22:00",
                duration: 1800,
                description: "Read a few chapters of a relaxing book in bed to easily fall into a deep sleep!!",
            )
        ],
        intensity: .low
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
