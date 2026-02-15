//
//  OnboardingCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func didTapGetStarted()
    func didFinishEnergyPeak()
    func didFinishFocusBegin()
    func didFinishProfessionalLife()
    func didFinishUltimateGoal()
    func didFinishOnboarding()
}

final class OnboardingCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var delegate: OnboardingCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        
        navigationController.pushViewController(onboardingVC, animated: true)
    }
}
