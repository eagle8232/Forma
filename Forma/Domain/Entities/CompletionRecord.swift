import Foundation

struct CompletionRecord: Identifiable, Codable {
    let id: String
    let routineId: String
    let date: Date
    let completedTasks: [String: Bool]
    let totalTasks: Int
    let completedCount: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedCount) / Double(totalTasks)
    }
    
    var score: Int {
        Int(completionRate * 100)
    }
}
