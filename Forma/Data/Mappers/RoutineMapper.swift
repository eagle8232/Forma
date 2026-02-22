//
//  RoutineMapper.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

extension RoutineDTO {
    
    func toEntity() -> RoutineBlock {
        return RoutineBlock(
            id: self.id ?? UUID().uuidString,
            title: self.name ?? "Untitled Routine",
            startTime: formatTime(self.startTime),
            endTime: formatTime(self.endTime),
            icon: self.iconString ?? "⚡️",
            accentColor: self.colorString ?? "#4F9EF8",
            tasks: self.activities?.map { $0.toEntity() } ?? [],
            intensity: self.intensity
        )
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "00:00 AM" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

extension RoutineBlock {
    
    func toDTO() -> RoutineDTO {
        return RoutineDTO(
            id: self.id,
            name: self.title,
            description: self.description,
            iconString: self.icon,
            colorString: self.accentColor,
            startTime: parseTime(self.startTime),
            endTime: parseTime(self.endTime),
            activities: self.tasks.map { $0.toDTO() },
            intensity: self.intensity
        )
    }
    
    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        // If only time is provided, use today's date
        if let time = formatter.date(from: timeString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: time)
            return calendar.date(bySettingHour: components.hour ?? 0,
                                minute: components.minute ?? 0,
                                second: 0,
                                of: Date())
        }
        
        return nil
    }
}
