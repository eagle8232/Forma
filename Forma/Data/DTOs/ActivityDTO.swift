//
//  ActivityDTO.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

struct ActivityDTO: Codable {
    let id: String?
    var name: String?
    var desciption: String?
    var startTime: Date?
    var endTime: Date?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case desciption
        case startTime
        case endTime
    }
}
