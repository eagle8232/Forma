//
//  TaskDropDelegate.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/16/26.
//

import SwiftUI

struct TaskDropDelegate: DropDelegate {
    let task: RoutineTask
    let vm: RoutineDetailViewModel

    // Called when drag hovers over this row
    func dropEntered(info: DropInfo) {
        guard
            let draggingID = vm.draggingTaskID,
            draggingID != task.id,
            let fromIndex = vm.tasks.firstIndex(where: { $0.id == draggingID }),
            let toIndex   = vm.tasks.firstIndex(where: { $0.id == task.id })
        else { return }

        vm.draggingTargetID = task.id

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            vm.moveTasks(
                from: IndexSet(integer: fromIndex),
                to: toIndex > fromIndex ? toIndex + 1 : toIndex
            )
        }
    }

    func dropExited(info: DropInfo) {
        vm.draggingTargetID = nil
    }

    // Must return true to accept the drop
    func performDrop(info: DropInfo) -> Bool {
        vm.draggingTaskID   = nil
        vm.draggingTargetID = nil
        return true
    }

    // Prevents the default drop animation fighting ours
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
