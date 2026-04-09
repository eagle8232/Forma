import UIKit
import SwiftUI

extension HomeCoordinator {
    
    func showFocusMode(task: RoutineTask, routine: RoutineBlock, user: User) {
        let focusView = FocusModeView(
            task: task,
            routineName: routine.title,
            profession: user.preferences?.profession ?? "Professional",
            onStepAway: { [weak self] steppedAwayTask in
                self?.handleTaskStepAway(steppedAwayTask, from: routine)
            }
        )
        
        let hostingController = FormaHostingController(rootView: focusView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        navigationController.present(hostingController, animated: true)
    }
    
    private func handleTaskStepAway(_ task: RoutineTask, from routine: RoutineBlock) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.showRoutineDetails(routine)
        }
    }
}
