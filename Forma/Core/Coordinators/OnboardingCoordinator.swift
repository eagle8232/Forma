//
//  OnboardingCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func didTapSignIn(_ coordinator: OnboardingCoordinator)
    func didFinish(_ coordinator: OnboardingCoordinator, with userPreferences: UserPreferences)
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
        onboardingVC.coordinator = self
        navigationController.setViewControllers([onboardingVC], animated: true)
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
    
    func showProfessionalLifeScreen(_ preferences: UserPreferences) {
        let professionalLifeVC = ProfessionalLifeViewController()
        professionalLifeVC.userPreferences = preferences
        professionalLifeVC.coordinator = self
        navigationController.pushViewController(professionalLifeVC, animated: true)
    }
    
    func showUltimateGoalScreen(_ preferences: UserPreferences) {
        let ultimateGoalVC = UltimateGoalViewController()
        ultimateGoalVC.userPreferences = preferences
        ultimateGoalVC.coordinator = self
        navigationController.pushViewController(ultimateGoalVC, animated: true)
    }
    
    func didFinishOnboarding(_ preferences: UserPreferences) {
        delegate?.didFinish(self, with: preferences)
    }
    
    func didTapSignIn() {
        delegate?.didTapSignIn(self)
    }
}
