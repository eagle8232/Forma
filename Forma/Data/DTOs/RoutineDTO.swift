//
//  RoutineDTO.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

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
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case iconString
        case colorString
        case startTime
        case endTime
        case activities
        case intensity
    }
}
