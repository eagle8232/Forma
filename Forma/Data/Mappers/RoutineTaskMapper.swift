//
//  ActivityMapper.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

// RoutineTask+Mapper.swift

import Foundation

extension RoutineTaskDTO {
    
    func toEntity() -> RoutineTask {
        return RoutineTask(
            id: self.id ?? UUID().uuidString,
            title: self.name ?? "Untitled Task",
            startTime: self.startTime ?? "00:00",
            duration: self.duration ?? 0,
            description: self.description ?? "",
            state: self.state ?? .upcoming
        )
    }
}

extension RoutineTask {
    
    func toDTO() -> RoutineTaskDTO {
        return RoutineTaskDTO(
            id: self.id,
            name: self.title,
            startTime: self.startTime,
            description: self.description,
            duration: self.duration,
            state: self.state
        )
    }
}
