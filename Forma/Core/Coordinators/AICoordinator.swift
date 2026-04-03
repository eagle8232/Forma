import UIKit
import SwiftUI

protocol AIGenerationCoordinatorDelegate: AnyObject {
    func didGenerateRoutines(_ coordinator: AICoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock])
    func didRequestSignUp(_ coordinator: AICoordinator, with userPreferences: UserPreferences, routines: [RoutineBlock])
}

extension AIGenerationCoordinatorDelegate {
    func didGenerateRoutines(_ coordinator: AICoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock]) {}
}

class AICoordinator: Coordinator {
    
    weak var delegate: AIGenerationCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func showAIGeneration(with userPreferences: UserPreferences) {
        let vc = AIGenerationHostingController(rootView: AIGenerationView(userPreferences: userPreferences, coordinator: self))
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showRoutineDetailView(routine: RoutineBlock, onSave: @escaping (RoutineBlock) -> Void) {
        let vc = FormaHostingController(rootView: RoutineDetailView(routine: routine, onSave: onSave))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showAIAssistant() {
        let vc = FormaHostingController(rootView: AIAssistantView())
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func didTapStartButton(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        delegate?.didRequestSignUp(self, with: userPreferences, routines: routines)
    }
}

