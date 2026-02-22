//
//  AIGenerationCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit

protocol AIGenerationCoordinatorDelegate: AnyObject {
    func didGenerateRoutines(_ coordinator: AIGenerationCoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock])
    func didRequestSignUp(_ coordinator: AIGenerationCoordinator,
                          with userPreferences: UserPreferences,
                          routines: [RoutineBlock])
}

extension AIGenerationCoordinatorDelegate {
    func didGenerateRoutines(_ coordinator: AIGenerationCoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock]) {}
}

class AIGenerationCoordinator: Coordinator {
    
    weak var delegate: AIGenerationCoordinatorDelegate?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var userPreferences: UserPreferences
    
    init(navigationController: UINavigationController, userPreferences: UserPreferences) {
        self.navigationController = navigationController
        self.userPreferences = userPreferences
    }
    
    func start() {
        let aiGenerationVC = AIGenerationViewController()
        aiGenerationVC.coordinator = self
        navigationController.setViewControllers([aiGenerationVC], animated: true)
    }
    
    func showResultsScreen(routines: [RoutineBlock]) {
        let aiResultsVC = AIResultsViewController()
        aiResultsVC.coordinator = self
        aiResultsVC.configure(with: self.userPreferences, routines: routines)
        navigationController.setViewControllers([aiResultsVC], animated: true)
    }
    
    func didTapStartButton(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        delegate?.didRequestSignUp(self, with: userPreferences, routines: routines)
    }
}

