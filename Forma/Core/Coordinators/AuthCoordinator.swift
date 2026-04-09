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
        print("[AuthCoordinator] start() called")
        showSignInScreen()
    }
    
    func showSignInScreen() {
        print("[AuthCoordinator] showSignInScreen() called")
        let authVC = AuthHostingController(rootView: AuthView { [weak self] user in
            self?.didCompleteSignIn(with: user)
        }, onDismiss: { [weak self] in
            self?.dismissAuth()
        })
        print("[AuthCoordinator] Pushing AuthVC")
        navigationController.pushViewController(authVC, animated: true)
        print("[AuthCoordinator] Push completed. VCs: \(navigationController.viewControllers.count)")
    }
    
    private func dismissAuth() {
        navigationController.popViewController(animated: true)
    }
    
    func showSignUpScreen(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        let authVC = AuthHostingController(rootView: AuthView(
            userPreferences: userPreferences,
            routines: routines,
            onSuccess: { [weak self] user in
                self?.didCompleteSignUp(with: user, routines: routines)
            }), onDismiss: { [weak self] in
                self?.dismissAuth()
            })
        navigationController.pushViewController(authVC, animated: true)
    }
    
    private func didCompleteSignIn(with user: User) {
        delegate?.didCompleteSignIn(self, with: user)
    }
    
    private func didCompleteSignUp(with user: User, routines: [RoutineBlock]) {
        delegate?.didCompleteSignUp(self, with: user, routines: routines)
    }
}
