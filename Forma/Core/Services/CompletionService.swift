import Foundation

final class CompletionService {
    
    static let shared = CompletionService()
    
    private let repository: CompletionRepositoryProtocol
    
    private init() {
        self.repository = CompletionRepository()
    }
    
    // MARK: - Save Completion
    
    func saveCompletion(routineId: String, completedTasks: [String: Bool]) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id else { return }
        
        print("[DEBUG] saveCompletion called for routine: \(routineId)")
        print("[DEBUG] completedTasks: \(completedTasks)")
        
        let record = CompletionRecord(
            id: UUID().uuidString,
            routineId: routineId,
            date: Date(),
            completedTasks: completedTasks,
            totalTasks: completedTasks.count,
            completedCount: completedTasks.values.filter { $0 }.count
        )
        
        CoreDataManager.shared.saveCompletionRecord(
            routineId: routineId,
            completedTasks: completedTasks,
            userId: userId
        )
        
        Task {
            try? await repository.saveCompletionRecord(record, userId: userId)
        }
    }
    
    // MARK: - Statistics
    
    func getStreak() -> Int {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id else { return 0 }
        return CoreDataManager.shared.fetchStreak(forUserId: userId)
    }
    
    func getTodayScore() -> Int {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return 0 }
        
        var totalTasks = 0
        var completedTasks = 0
        
        for routine in routines {
            if let record = CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) {
                totalTasks += record.totalTasks
                completedTasks += record.completedCount
            }
        }
        
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalTasks)) * 100)
    }
    
    func getTodayTasksStats() -> (completed: Int, total: Int) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return (0, 0) }
        
        var totalTasks = 0
        var completedTasks = 0
        
        for routine in routines {
            if let record = CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) {
                totalTasks += record.totalTasks
                completedTasks += record.completedCount
            }
        }
        
        return (completedTasks, totalTasks)
    }
    
    func getTodayRoutinesStats(userId: String) -> (completed: Int, total: Int) {
        var routines = DependencyContainer.shared.routines
        
        if routines == nil {
            routines = CoreDataManager.shared.fetchRoutines(forUserId: userId)
        }
        
        guard let finalRoutines = routines else { return (0, 0) }
        
        var completedRoutines = 0
        let totalRoutines = finalRoutines.count
        
        for routine in finalRoutines {
            if CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) != nil {
                completedRoutines += 1
            }
        }
        
        return (completedRoutines, totalRoutines)
    }
    
    func getTodayCompletedRoutinesCount(userId: String) -> Int {
        let routines = DependencyContainer.shared.routines
        
        guard let finalRoutines = routines else { return 0 }
        
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(date: Date())
        
        var completedRoutines = 0
        
        for routine in finalRoutines {
            let endTimeInSeconds = DateManager.shared.convertToSeconds(string: routine.endTime)
            
            if currentTimeInSeconds >= endTimeInSeconds {
                if CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) != nil {
                    completedRoutines += 1
                }
            }
        }
        
        return completedRoutines
    }
    
    func getTodayHours() -> Double {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return 0 }
        
        var totalMinutes = 0
        
        for routine in routines {
            if let record = CoreDataManager.shared.fetchTodayCompletionRecord(forUserId: userId, routineId: routine.id) {
                for task in routine.tasks where !task.isBreak {
                    if record.completedTasks[task.id] == true {
                        totalMinutes += task.duration
                    }
                }
            }
        }
        
        return Double(totalMinutes) / 60.0
    }
    
    func getWeeklyStats() -> (score: Int, hours: Double, completedRoutines: Int) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return (0, 0, 0) }
        
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        let records = CoreDataManager.shared.fetchCompletionRecords(forUserId: userId, from: startOfWeek, to: endOfWeek)
        
        var totalScore = 0
        var totalMinutes = 0
        let completedRoutineIds = Set(records.map { $0.routineId })
        
        for record in records {
            totalScore += record.score
            if let routine = routines.first(where: { $0.id == record.routineId }) {
                for task in routine.tasks where !task.isBreak {
                    if record.completedTasks[task.id] == true {
                        totalMinutes += task.duration
                    }
                }
            }
        }
        
        let avgScore = records.isEmpty ? 0 : totalScore / records.count
        
        return (avgScore, Double(totalMinutes) / 60.0, completedRoutineIds.count)
    }
    
    func getMonthlyStats() -> (score: Int, hours: Double, completedRoutines: Int) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return (0, 0, 0) }
        
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        
        let records = CoreDataManager.shared.fetchCompletionRecords(forUserId: userId, from: startOfMonth, to: endOfMonth)
        
        var totalScore = 0
        var totalMinutes = 0
        let completedRoutineIds = Set(records.map { $0.routineId })
        
        for record in records {
            totalScore += record.score
            if let routine = routines.first(where: { $0.id == record.routineId }) {
                for task in routine.tasks where !task.isBreak {
                    if record.completedTasks[task.id] == true {
                        totalMinutes += task.duration
                    }
                }
            }
        }
        
        let avgScore = records.isEmpty ? 0 : totalScore / records.count
        
        return (avgScore, Double(totalMinutes) / 60.0, completedRoutineIds.count)
    }
    
    func getStats(for date: Date) -> (score: Int, hours: Double, completedTasks: Int) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return (0, 0, 0) }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let records = CoreDataManager.shared.fetchCompletionRecords(forUserId: userId, from: startOfDay, to: endOfDay)
        
        var totalMinutes = 0
        var totalCompletedTasks = 0
        var totalAllTasks = 0
        
        for record in records {
            totalCompletedTasks += record.completedCount
            totalAllTasks += record.totalTasks
            if let routine = routines.first(where: { $0.id == record.routineId }) {
                for task in routine.tasks where !task.isBreak {
                    if record.completedTasks[task.id] == true {
                        totalMinutes += task.duration
                    }
                }
            }
        }
        
        let score = totalAllTasks > 0 ? Int((Double(totalCompletedTasks) / Double(totalAllTasks)) * 100) : 0
        
        return (score, Double(totalMinutes) / 60.0, totalCompletedTasks)
    }
    
    func getYearStats() -> (score: Int, hours: Double, completedRoutines: Int) {
        guard let userId = DependencyContainer.shared.currentUser?.credentials.id,
              let routines = DependencyContainer.shared.routines else { return (0, 0, 0) }
        
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
        
        let records = CoreDataManager.shared.fetchCompletionRecords(forUserId: userId, from: startOfYear, to: endOfYear)
        
        guard !records.isEmpty else { return (0, 0, 0) }
        
        var totalMinutes = 0
        let completedRoutineIds = Set(records.map { $0.routineId })
        
        for record in records {
            if let routine = routines.first(where: { $0.id == record.routineId }) {
                for task in routine.tasks where !task.isBreak {
                    if record.completedTasks[task.id] == true {
                        totalMinutes += task.duration
                    }
                }
            }
        }
        
        let avgScore = records.reduce(0) { $0 + $1.score } / records.count
        
        return (avgScore, Double(totalMinutes) / 60.0, completedRoutineIds.count)
    }
}
