import Foundation

struct RoutineDTO: Codable {
    let id: String?
    var name: String?
    var description: String?
    var iconString: String?
    var colorString: String?
    var startTime: String?
    var endTime: String?
    var activities: [RoutineTaskDTO]?
    var intensity: BlockIntensity?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, iconString, colorString, startTime, endTime, activities, intensity
    }
}
