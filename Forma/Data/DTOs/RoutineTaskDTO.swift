import Foundation

struct RoutineTaskDTO: Codable {
    let id: String?
    var name: String?
    var startTime: String?
    var description: String?
    var duration: Int?
    var state: TaskState?
    var intensity: BlockIntensity?
    var isBreak: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, startTime, description, duration, state, intensity, isBreak
    }
}
