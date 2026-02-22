//
//  AIResultsViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import Foundation
import Combine

final class AIResultsViewModel {
    
    // MARK: - Published Properties
    
    @Published var routines: [RoutineBlock] = []
    @Published var isEditMode: Bool = false
    @Published var selectedRoutineForEdit: RoutineBlock?
    
    // MARK: - Properties
    
    let userPreferences: UserPreferences
    
    // MARK: - Initialization
    
    init(userPreferences: UserPreferences, routines: [RoutineBlock]) {
        self.userPreferences = userPreferences
        self.routines = routines
    }
    
    // MARK: - Public Methods
    
    func toggleTask(taskId: String, isCompleted: Bool, in routine: RoutineBlock) {
        guard let routineIndex = routines.firstIndex(where: { $0.id == routine.id }) else {
            return
        }
        
        var updatedRoutine = routines[routineIndex]
        
        if let taskIndex = updatedRoutine.tasks.firstIndex(where: { $0.id == taskId }) {
            updatedRoutine.tasks[taskIndex].isCompleted = isCompleted
            routines[routineIndex] = updatedRoutine
            
            print("✅ Task updated: \(updatedRoutine.tasks[taskIndex].title) - \(isCompleted)")
        }
    }
    
    func deleteRoutine(_ routine: RoutineBlock) {
        routines.removeAll { $0.id == routine.id }
        print("🗑️ Routine deleted: \(routine.title)")
    }
    
    func duplicateRoutine(_ routine: RoutineBlock) {
        var duplicated = routine
        duplicated.id = UUID().uuidString
        
        // Insert after original
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines.insert(duplicated, at: index + 1)
        }
        
        print("📋 Routine duplicated: \(routine.title)")
    }
    
    func moveRoutine(from source: Int, to destination: Int) {
        guard source != destination,
              source >= 0, source < routines.count,
              destination >= 0, destination < routines.count else {
            return
        }
        
        let routine = routines.remove(at: source)
        routines.insert(routine, at: destination)
        
        print("🔄 Routine moved from \(source) to \(destination)")
    }
    
    func selectRoutineForEdit(_ routine: RoutineBlock) {
        selectedRoutineForEdit = routine
    }
    
    func updateRoutine(_ updatedRoutine: RoutineBlock) {
        if let index = routines.firstIndex(where: { $0.id == updatedRoutine.id }) {
            routines[index] = updatedRoutine
            print("✏️ Routine updated: \(updatedRoutine.title)")
        }
    }
    
    func getTotalDuration() -> String {
        let totalMinutes = routines.reduce(0) { total, routine in
            return total + routine.tasks.reduce(0) { taskTotal, task in
                return taskTotal + parseDuration(task.duration)
            }
        }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getCompletionPercentage() -> Float {
        let totalTasks = routines.flatMap { $0.tasks }.count
        guard totalTasks > 0 else { return 0 }
        
        let completedTasks = routines.flatMap { $0.tasks }.filter { $0.isCompleted }.count
        return Float(completedTasks) / Float(totalTasks)
    }
    
    // MARK: - Private Helpers
    
    private func parseDuration(_ durationString: String) -> Int {
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
        
        return totalMinutes
    }
}
