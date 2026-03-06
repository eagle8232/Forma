//
//  HomeViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/25/26.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published var selectedRoutine: RoutineBlock?
    var currentTask: RoutineTask?
    var routines: [RoutineBlock]
    
    private let today = Date()
    
    init(routines: [RoutineBlock]) {
        self.routines = routines
        self.selectedRoutine = decideRoutineSelection()
    }
    
    func setSelectedRoutine(_ routine: RoutineBlock) {
        selectedRoutine = routine
    }
    
    // MARK: - Public Methods
    public func getDate(isWeekday: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        let dateString = dateFormatter.string(from: today)
        
        let calendar = Calendar.current
        let weekdayString = calendar.weekdaySymbols[calendar.component(.weekday, from: today) - 1]
        
        return [weekdayString, dateString].joined(separator: ", ")
    }
    
    func decideRoutineSelection() -> RoutineBlock {
        let today = DateManager.shared.getTodayTimeString()
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(today)
        
        var routineForSelection: RoutineBlock?
        routines.enumerated().forEach { [weak self] routineIndex, routine in
            guard let self else { return }
            
            let routineStartTimeInSeconds = DateManager.shared.convertToSeconds(self.routines[routineIndex].startTime)
            
            if currentTimeInSeconds >= routineStartTimeInSeconds {
                routineForSelection = routine
            }
            
            routine.tasks.enumerated().forEach { taskIndex, task in
                let taskStartTimeInSeconds = DateManager.shared.convertToSeconds(task.startTime)
                if currentTimeInSeconds > taskStartTimeInSeconds {
                    self.currentTask = task
                    self.routines[routineIndex].tasks[taskIndex].state = .completed
                } else {
                    self.routines[routineIndex].tasks[taskIndex].state = .upcoming
                }
            }
        }
        return routineForSelection ?? .mockWork
    }
}
