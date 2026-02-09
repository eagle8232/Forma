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
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case email
    }
}


struct UserDTO: Codable {
    var userCredentials: UserCredentialsDTO?
    var profession: String?
    var sleepTime: Date?
    var wakeUpTime: Date?
    var focusTime: Date?
    var goal: String?
    var routines: [RoutineDTO]?
    let isAnonymous: Bool?
    
    enum CodingKeys: CodingKey {
        case userCredentials
        case profession
        case sleepTime
        case wakeUpTime
        case focusTime
        case goal
        case routines
        case isAnonymous
    }
}
