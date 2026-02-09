//
//  UserDTO.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

struct UserCredentialsDTO: Codable {
    let id: String?
    var name: String?
    var email: String?
    var isAnonymous: Bool?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case email
        case isAnonymous
    }
}

struct UserPreferencesDTO: Codable {
    var profession: String?
    var sleepTime: Date?
    var wakeUpTime: Date?
    var focusTime: Date?
    var goal: String?
    
    enum CodingKeys: CodingKey {
        case profession
        case sleepTime
        case wakeUpTime
        case focusTime
        case goal
    }
}


struct UserDTO: Codable {
    var credentials: UserCredentialsDTO?
    var preferences: UserPreferencesDTO?
    
    enum CodingKeys: CodingKey {
        case credentials
        case preferences
    }
}
