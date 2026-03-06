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
    var startTime: String?
    var description: String?
    var duration: Int?
    var state: TaskState?
    var intenisty: BlockIntensity?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case startTime
        case description
        case duration
        case state
    }
}
