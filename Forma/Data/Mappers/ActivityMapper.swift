//
//  ActivityMapper.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

extension ActivityDTO {
    
    func toEntity() -> Activity {
        return Activity(
            id: self.id ?? "",
            name: self.name ?? "No name",
            desciption: self.desciption ?? "No description",
            startTime: self.startTime ?? Date(),
            endTime: self.endTime ?? Date()
        )
    }
}

extension Activity {
    
    func toDTO() -> ActivityDTO {
        return ActivityDTO(
            id: self.id,
            name: self.name,
            desciption: self.desciption,
            startTime: self.startTime,
            endTime: self.endTime
        )
    }
}

