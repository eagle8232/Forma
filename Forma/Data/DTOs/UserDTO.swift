//
//  UserDTO.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

struct UserDTO: Codable {
    var id: String?
    var name: String?
    var email: String?
    var profession: String?
    var sleepTime: Date?
    var wakeUpTime: Date?
    var focusTime: Date?
    var goal: String?
    let isAnonymous: Bool?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case email
        case profession
        case sleepTime
        case wakeUpTime
        case focusTime
        case goal
        case isAnonymous
    }
}
