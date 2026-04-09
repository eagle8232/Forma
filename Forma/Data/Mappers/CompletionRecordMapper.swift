import Foundation

extension CompletionRecordDTO {
    func toEntity() -> CompletionRecord? {
        guard let id = self.id,
              let routineId = self.routineId,
              let date = self.date,
              let completedTasks = self.completedTasks,
              let totalTasks = self.totalTasks,
              let completedCount = self.completedCount else {
            return nil
        }
        
        return CompletionRecord(
            id: id,
            routineId: routineId,
            date: date,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            completedCount: completedCount
        )
    }
}

extension CompletionRecord {
    func toDTO() -> CompletionRecordDTO {
        CompletionRecordDTO(
            id: self.id,
            routineId: self.routineId,
            date: self.date,
            completedTasks: self.completedTasks,
            totalTasks: self.totalTasks,
            completedCount: self.completedCount,
            score: self.score
        )
    }
}
