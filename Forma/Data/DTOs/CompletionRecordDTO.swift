import Foundation

struct CompletionRecordDTO: Codable {
    var id: String?
    var routineId: String?
    var date: Date?
    var completedTasks: [String: Bool]?
    var totalTasks: Int?
    var completedCount: Int?
    var score: Int?

    enum CodingKeys: String, CodingKey {
        case id, routineId, date, completedTasks, totalTasks, completedCount, score
    }
}
