//
//  OnboardingCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func didTapSignIn(_ coordinator: OnboardingCoordinator)
    func didTapGetStarted(_ coordinator: OnboardingCoordinator)
}

extension OnboardingCoordinatorDelegate {
    func didTapGetStarted(_ coordinator: OnboardingCoordinator) {}
}

final class OnboardingCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    weak var delegate: OnboardingCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.onboardingCoordinator = self
        navigationController.pushViewController(onboardingVC, animated: true)
    }
    
    func showEnergyPeakScreen() {
        let energyPeakVC = EnergyPeakViewController()
        energyPeakVC.coordinator = self
        navigationController.pushViewController(energyPeakVC, animated: true)
    }
    
    func showFocusBeginScreen(_ preferences: UserPreferences) {
        let focusBeginVC = FocusBeginViewController()
        focusBeginVC.userPreferences = preferences
        focusBeginVC.coordinator = self
        navigationController.pushViewController(focusBeginVC, animated: true)
    }
}
