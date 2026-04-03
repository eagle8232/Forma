import Foundation

struct RoutineTask: Identifiable, Equatable, Codable {
    let id: String
    var title: String
    var startTime: String
    var duration: Int
    var description: String?
    var state: TaskState = .upcoming
    var isBreak: Bool = false
    
    var durationText: String {
        duration < 60 ? "\(duration) mins" : "\(duration / 60)h \(duration % 60 > 0 ? "\(duration % 60)m" : "")"
    }
}

enum TaskState: String, Codable {
    case upcoming
    case inProgress
    case completed
}
