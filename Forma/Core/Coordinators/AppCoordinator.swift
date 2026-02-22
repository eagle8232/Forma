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
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showAuthScreen(_ userPreferences: UserPreferences? = nil, routines: [RoutineBlock]? = nil) {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        addChild(authCoordinator)
        
        if let userPreferences, let routines {
            authCoordinator.showSignUpScreen(with: userPreferences, routines: routines)
        } else {
            authCoordinator.start()
        }
    }
    
    func showAIGeneration(with userPreferences: UserPreferences) {
        let aiGenerationCoordinator = AIGenerationCoordinator(navigationController: navigationController, userPreferences: userPreferences)
        aiGenerationCoordinator.delegate = self
        addChild(aiGenerationCoordinator)
        aiGenerationCoordinator.start()
    }
    
    func showMainFlow() {
        // This is called when Auth is successful
    }
}


// MARK: - Onboarding Coordinator Delegate
extension AppCoordinator: OnboardingCoordinatorDelegate {
    
    func didTapSignIn(_ coordinator: OnboardingCoordinator) {
        showAuthScreen()
    }
    
    func didFinish(_ coordinator: OnboardingCoordinator, with userPreferences: UserPreferences) {
        removeChild(coordinator)
        showAIGeneration(with: userPreferences)
    }
}

// MARK: - Onboarding Coordinator Delegate
extension AppCoordinator: AuthCoordinatorDelegate {
    func didCancelAuth(_ coordinator: AuthCoordinator) {
        removeChild(coordinator)
    }
    
    func didCompleteSignIn(_ coordinator: AuthCoordinator) {
        let vc = HomeViewController()
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func didCompleteSignUp(_ coordinator: AuthCoordinator, with user: User, routines: [RoutineBlock]) {
        // TODO: - Show Main Flow Action
    }
}

// MARK: - AI Generation Coordinator Delegate
extension AppCoordinator: AIGenerationCoordinatorDelegate {
    func didRequestSignUp(_ coordinator: AIGenerationCoordinator, with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        showAuthScreen(userPreferences, routines: routines)
    }
}
