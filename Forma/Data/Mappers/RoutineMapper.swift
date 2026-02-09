//
//  RoutineMapper.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

extension RoutineDTO{
    
    func toEntity() -> Routine {
        return Routine(
            id: self.id ?? "",
            name: self.name ?? "No name",
            description: self.description ?? "No description",
            iconString: self.iconString ?? "",
            colorString: self.colorString ?? "",
            startTime: self.startTime ?? Date(),
            endTime: self.endTime ?? Date(),
            activities: self.activities?.map{$0.toEntity()} ?? []
        )
    }
}

extension Routine {
    
    func toDTO() -> RoutineDTO {
        return RoutineDTO(
            id: self.id,
            name: self.name,
            description: self.description,
            iconString: self.iconString,
            colorString: self.colorString,
            startTime: self.startTime,
            endTime: self.endTime,
            activities: self.activities.map{$0.toDTO()}
        )
    }
}
