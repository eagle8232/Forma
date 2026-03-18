//
//  AuthCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit
import SwiftUI

protocol AuthCoordinatorDelegate: AnyObject {
    func didCancelAuth(_ coordinator: AuthCoordinator)
    func didCompleteSignIn(_ coordinator: AuthCoordinator, with user: User)
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
        let authVC = UIHostingController(rootView: AuthView { [weak self] user in
                self?.didCompleteSignIn(with: user)
            })
        navigationController.pushViewController(authVC, animated: true)
    }
    
    /// Show Sign Up screen with user data from onboarding
    func showSignUpScreen(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        let authVC = UIHostingController(rootView: AuthView(
            userPreferences: userPreferences,
            routines: routines,
            onSuccess: { [weak self] user in
                self?.didCompleteSignUp(with: user, routines: routines)
            }))
        navigationController.pushViewController(authVC, animated: true)
    }
    
    // MARK: - Completion
    
    func didCompleteSignIn(with user: User) {
        delegate?.didCompleteSignIn(self, with: user)
    }
    
    func didCompleteSignUp(with user: User, routines: [RoutineBlock]) {
        delegate?.didCompleteSignUp(self, with: user, routines: routines)
    }
}
