//
//  AIGenerationCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit
import SwiftUI

protocol AIGenerationCoordinatorDelegate: AnyObject {
    func didGenerateRoutines(_ coordinator: AIGenerationCoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock])
    func didRequestSignUp(_ coordinator: AIGenerationCoordinator,
                          with userPreferences: UserPreferences,
                          routines: [RoutineBlock])
//    func didTapRoutineDetailButton(_ coordinator: AIGenerationCoordinator, routine: RoutineBlock)
}

extension AIGenerationCoordinatorDelegate {
    func didGenerateRoutines(_ coordinator: AIGenerationCoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock]) {}
}

class AIGenerationCoordinator: Coordinator {
    
    weak var delegate: AIGenerationCoordinatorDelegate?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    var userPreferences: UserPreferences
    var newGeneratedRoutines: [RoutineBlock] = [] // - We store routines to be able to save routines later
    
    init(navigationController: UINavigationController, userPreferences: UserPreferences) {
        self.navigationController = navigationController
        self.userPreferences = userPreferences
    }
    
    func start() {
        let aiGenerationVC = UIHostingController(rootView: AIGenerationSwiftUIView(userPreferences: userPreferences, coordinator: self))
        navigationController.setViewControllers([aiGenerationVC], animated: true)
    }
    
    func showRoutineDetailView(routine: RoutineBlock, _ onSave: @escaping ((RoutineBlock) -> Void)) {
        let routineDetailVC = UIHostingController(rootView: RoutineDetailView(
            routine: routine,
            onSave: onSave
        ))
        navigationController.pushViewController(routineDetailVC, animated: true)
    }
    
    func showResultsScreen(routines: [RoutineBlock]) {
        let aiResultsVC = AIResultsViewController()
        aiResultsVC.coordinator = self
        aiResultsVC.configure(with: self.userPreferences, routines: routines)
        navigationController.setViewControllers([aiResultsVC], animated: true)
    }
    
    func saveNewGeneratedRoutines(_ routines: [RoutineBlock]) { self.newGeneratedRoutines = routines }
    
    func didTapStartButton(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        delegate?.didRequestSignUp(self, with: userPreferences, routines: routines)
    }
}

