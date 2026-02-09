//
//  Activity.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct Activity: Identifiable {
    let id: String
    var name: String
    var desciption: String
    var startTime: Date
    var endTime: Date
    var isCompleted: Bool
}
