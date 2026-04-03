import Foundation

struct UserCredentialsDTO: Codable {
    let id: String?
    var name: String?
    var email: String?
    var isAnonymous: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, isAnonymous
    }
}

struct UserPreferencesDTO: Codable {
    var profession: String?
    var sleepTime: Date?
    var wakeUpTime: Date?
    var focusTime: Date?
    var goal: [String]?
    var prayerFrequency: String?
    var workStyle: String?
    var exerciseTime: String?
    var lunchBreak: String?
    var additionalContext: String?
    
    enum CodingKeys: String, CodingKey {
        case profession, sleepTime, wakeUpTime, focusTime, goal, prayerFrequency, workStyle, exerciseTime, lunchBreak, additionalContext
    }
}

struct UserDTO: Codable {
    var credentials: UserCredentialsDTO?
    var preferences: UserPreferencesDTO?
    
    enum CodingKeys: String, CodingKey {
        case credentials, preferences
    }
}
