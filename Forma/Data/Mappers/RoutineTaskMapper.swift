import Foundation

extension RoutineTaskDTO {
    func toEntity() -> RoutineTask {
        RoutineTask(
            id: self.id ?? UUID().uuidString,
            title: self.name ?? "Untitled Task",
            startTime: self.startTime ?? "00:00",
            duration: self.duration ?? 0,
            description: self.description ?? "",
            state: self.state ?? .upcoming,
            isBreak: self.isBreak ?? false
        )
    }
}

extension RoutineTask {
    func toDTO() -> RoutineTaskDTO {
        RoutineTaskDTO(
            id: self.id,
            name: self.title,
            startTime: self.startTime,
            description: self.description,
            duration: self.duration,
            state: self.state,
            isBreak: self.isBreak
        )
    }
}
