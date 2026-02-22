//
//  ActivityDTO.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

struct RoutineTaskDTO: Codable {
    let id: String?
    var name: String?
    var description: String?
    var startTime: Date?
    var endTime: Date?
    var isCompleted: Bool?
    var intenisty: BlockIntensity?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case startTime
        case endTime
        case isCompleted
    }
}
