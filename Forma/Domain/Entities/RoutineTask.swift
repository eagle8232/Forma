//
//  Activity.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct RoutineTask: Identifiable {
    let id: String
    var title: String
    var startTime: String
    var duration: Int
    var description: String
    var state: TaskState = .upcoming
}
