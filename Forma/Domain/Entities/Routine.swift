//
//  Routine.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct Routine: Identifiable {
    let id: UUID = UUID()
    var name: String
    var description: String
    var iconString: String
    var colorString: String
    var startTime: String
    var endTime: String
    var activities: [Activity]
}
