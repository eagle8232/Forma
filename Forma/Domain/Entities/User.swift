//
//  User.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct UserCredentials: Identifiable {
    let id: String
    var name: String
    var email: String
    var isAnonymous: Bool
}

struct UserPreferences {
    var profession: String
    var sleepTime: Date
    var wakeUpTime: Date
    var focusTime: Date?
    var goal: [String]
}

struct User {
    var credentials: UserCredentials
    var preferences: UserPreferences
}

// MARK: - Mock Data

extension UserCredentials {
    
    static let mockCredentialData = UserCredentials(id: UUID().uuidString,
                                          name: "Vusal",
                                          email: "vusunuriyev@gmail.com",
                                          isAnonymous: false)
}

extension UserPreferences {
    
    static let mockPreferencesData = UserPreferences(
        profession: ProfessionRole.developer.rawValue,
        sleepTime: DateHelper.today(at: 23, min: 0), // 11:00 PM
        wakeUpTime: DateHelper.today(at: 7, min: 0), // 07:00 AM
        focusTime: DateHelper.today(at: 9, min: 30), // 09:30 AM
        goal: [UltimateGoal.deepWorkFocus.rawValue,
               UltimateGoal.consistentExercise.rawValue,
               UltimateGoal.improveSleepHygiene.rawValue],
    )
}

extension User {
    
    static let mockUserData = User(
        credentials: .mockCredentialData,
        preferences: .mockPreferencesData,
    )
}
