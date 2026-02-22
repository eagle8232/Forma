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
            duration: formatDuration(start: self.startTime, end: self.endTime),
            description: self.description ?? "",
            isCompleted: self.isCompleted ?? false
        )
    }
    
    private func formatDuration(start: Date?, end: Date?) -> String {
        guard let start = start, let end = end else {
            return "0 mins"
        }
        
        let difference = end.timeIntervalSince(start)
        let minutes = Int(difference / 60)
        
        if minutes < 60 {
            return "\(minutes) mins"
        } else {
            let hours = minutes / 60
            let remainingMins = minutes % 60
            if remainingMins == 0 {
                return "\(hours) hr\(hours > 1 ? "s" : "")"
            } else {
                return "\(hours) hr \(remainingMins) mins"
            }
        }
    }
}

extension RoutineTask {
    
    func toDTO() -> RoutineTaskDTO {
        let (startTime, endTime) = parseDuration(self.duration)
        
        return RoutineTaskDTO(
            id: self.id,
            name: self.title,
            description: self.description,
            startTime: startTime,
            endTime: endTime,
            isCompleted: self.isCompleted
        )
    }
    
    private func parseDuration(_ durationString: String) -> (Date?, Date?) {
        let now = Date()
        
        // Parse duration string (e.g., "15 mins", "90 mins", "1 hr 30 mins")
        let components = durationString.lowercased().components(separatedBy: " ")
        var totalMinutes = 0
        
        var i = 0
        while i < components.count {
            if let value = Int(components[i]) {
                let unit = components.count > i + 1 ? components[i + 1] : ""
                
                if unit.hasPrefix("hr") || unit.hasPrefix("hour") {
                    totalMinutes += value * 60
                } else if unit.hasPrefix("min") {
                    totalMinutes += value
                }
                i += 2
            } else {
                i += 1
            }
        }
        
        let endTime = Calendar.current.date(byAdding: .minute,
                                            value: totalMinutes,
                                            to: now)
        
        return (now, endTime)
    }
}
