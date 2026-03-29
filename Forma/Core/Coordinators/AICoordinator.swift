//
//  AIGenerationCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit
import SwiftUI

protocol AIGenerationCoordinatorDelegate: AnyObject {
    func didGenerateRoutines(_ coordinator: AICoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock])
    func didRequestSignUp(_ coordinator: AICoordinator,
                          with userPreferences: UserPreferences,
                          routines: [RoutineBlock])
}

extension AIGenerationCoordinatorDelegate {
    func didGenerateRoutines(_ coordinator: AICoordinator, with userPreferences: UserPreferences, newRoutines routines: [RoutineBlock]) {}
}

class AICoordinator: Coordinator {
    
    weak var delegate: AIGenerationCoordinatorDelegate?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
    func showAIGeneration(with userPreferences: UserPreferences) {
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
    
    func showAIAssistant() {
        let aiAssistantVC = UIHostingController(rootView: AIAssistantView())
        navigationController.setViewControllers([aiAssistantVC], animated: true)
    }
    
    func didTapStartButton(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        delegate?.didRequestSignUp(self, with: userPreferences, routines: routines)
    }
}

