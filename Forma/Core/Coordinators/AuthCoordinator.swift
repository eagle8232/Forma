//
//  AuthCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func didCancelAuth(_ coordinator: AuthCoordinator)
    func didCompleteSignIn(_ coordinator: AuthCoordinator)
    func didCompleteSignUp(_ coordinator: AuthCoordinator, with user: User, routines: [RoutineBlock])
}

final class AuthCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSignInScreen()
    }
    
    func finish() {
        // Clean up if needed
    }
    
    // MARK: - Navigation
    
    /// Show Sign In screen (for returning users)
    func showSignInScreen() {
        let authVC = AuthViewController()
        authVC.coordinator = self
        navigationController.pushViewController(authVC, animated: true)
    }
    
    /// Show Sign Up screen with user data from onboarding
    func showSignUpScreen(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        let authVC = AuthViewController()
        authVC.viewModel.userPreferences = userPreferences
        authVC.viewModel.routines = routines
        authVC.coordinator = self
        navigationController.pushViewController(authVC, animated: true)
    }
    
    // MARK: - Completion
    
    func didCompleteSignIn() {
        delegate?.didCompleteSignIn(self)
    }
    
    func didCompleteSignUp(with user: User, routines: [RoutineBlock]) {
        delegate?.didCompleteSignUp(self, with: user, routines: routines)
    }
}
