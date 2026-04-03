import Foundation

extension RoutineDTO {
    func toEntity() -> RoutineBlock {
        RoutineBlock(
            id: self.id ?? UUID().uuidString,
            title: self.name ?? "Untitled Routine",
            startTime: self.startTime ?? "00:00",
            endTime: self.endTime ?? "00:00",
            icon: self.iconString ?? "⚡️",
            accentColor: self.colorString ?? "#4F9EF8",
            tasks: self.activities?.map { $0.toEntity() } ?? [],
            intensity: self.intensity
        )
    }
}

extension RoutineBlock {
    func toDTO() -> RoutineDTO {
        RoutineDTO(
            id: self.id,
            name: self.title,
            description: self.description,
            iconString: self.icon,
            colorString: self.accentColor,
            startTime: self.startTime,
            endTime: self.endTime,
            activities: self.tasks.map { $0.toDTO() },
            intensity: self.intensity
        )
    }
}
