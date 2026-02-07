//
//  Activity.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

struct Activity: Identifiable {
    let id: UUID = UUID()
    var name: String
    var desciption: String
    var startTime: Date
    var endTime: Date
}
