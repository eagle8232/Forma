//
//  Activity.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct RoutineTask: Identifiable, Equatable {
    let id: String
    var title: String
    var startTime: String
    var duration: Int
    var description: String?
    var state: TaskState = .upcoming
    
    var durationText: String {
        let mins = duration
        return mins < 60 ? "\(mins) mins" : "\(mins / 60)h \(mins % 60 > 0 ? "\(mins % 60)m" : "")"
    }
}

enum TaskState: String, Codable {
    case upcoming
    case inProgress
    case completed
}
