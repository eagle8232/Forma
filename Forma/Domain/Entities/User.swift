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
}

struct User {
    var userCredentials: UserCredentials
    var profession: String
    var sleepTime: Date
    var wakeUpTime: Date
    var focusTime: Date
    var goal: String
    var routines: [Routine]
    let isAnonymous: Bool
}

// MARK: - Mock Data

extension UserCredentials {
    
    static let mockData = UserCredentials(id: UUID().uuidString,
                                                    name: "Vusal",
                                                    email: "vusunuriyev@gmail.com")
}

extension User {
    
    static let mock = User(
        userCredentials: UserCredentials(
            id: "123",
            name: "Ali", 
            email: "ali@forma.app"
        ),
        profession: "iOS Developer",
        
        // Using helper to set specific times for TODAY
        sleepTime: DateHelper.today(at: 23, min: 0), // 11:00 PM
        wakeUpTime: DateHelper.today(at: 7, min: 0), // 07:00 AM
        focusTime: DateHelper.today(at: 9, min: 30), // 09:30 AM
        
        goal: "Build 3 income streams",
        routines: Routine.allMocks,
        isAnonymous: false
    )
}
