import Foundation

struct UserCredentials: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var isAnonymous: Bool
}

struct UserPreferences: Codable {
    var profession: String
    var sleepTime: Date
    var wakeUpTime: Date
    var focusTime: Date?
    var goal: [String]
    var workStyle: String?
    var exerciseTime: String?
    var lunchBreak: String?
    var additionalContext: String?
    var timezone: String?
    var appearanceMode: String?
    
    var resolvedTimezone: String {
        if let tz = timezone, !tz.isEmpty {
            return tz
        }
        return TimeZone.current.identifier
    }
    
    var resolvedAppearanceMode: AppearanceMode {
        if let mode = appearanceMode, let appearance = AppearanceMode(rawValue: mode) {
            return appearance
        }
        return .system
    }
}

struct User: Codable {
    var credentials: UserCredentials
    var preferences: UserPreferences?
}

extension UserCredentials {
    static let mockCredentialData = UserCredentials(
        id: UUID().uuidString,
        name: "Vusal",
        email: "vusunuriyev@gmail.com",
        isAnonymous: false
    )
}

extension UserPreferences {
    static let mockPreferencesData = UserPreferences(
        profession: ProfessionRole.developer.rawValue,
        sleepTime: DateHelper.today(at: 23, min: 0),
        wakeUpTime: DateHelper.today(at: 7, min: 0),
        focusTime: DateHelper.today(at: 9, min: 30),
        goal: [UltimateGoal.deepWorkFocus.rawValue, UltimateGoal.consistentExercise.rawValue, UltimateGoal.improveSleepHygiene.rawValue]
    )
}

extension User {
    static let mockUserData = User(
        credentials: .mockCredentialData,
        preferences: .mockPreferencesData
    )
}
