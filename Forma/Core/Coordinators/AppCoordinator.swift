//
//  AppCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import UIKit

public final class AppCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    private let window: UIWindow
    
    
    init(window: UIWindow,
         navigationController: UINavigationController = UINavigationController()) {
        
            self.window = window
            self.navigationController = navigationController
        }
    
    func start() {

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            showMainFlow()
        } else {
            showOnboardingView()
        }
    }
    
    func showOnboardingView() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.delegate = self
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showSignInScreen() {
        
    }
     
    func showSignUpScreen() {
        
    }
    
    func showMainFlow() {
        // This is called when Auth is successful
    }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
    
    func didTapSignIn(_ coordinator: OnboardingCoordinator) {
        // TODO: Push Sign In Screen Function
    }
}
