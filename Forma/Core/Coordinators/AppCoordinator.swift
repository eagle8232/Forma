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

        
        // - For testing
//        let testVC = HomeCoordinator(navigationController: self.navigationController)
//        testVC.showHomeView(with: RoutineBlock.allMocks)
    }
    
    func showOnboardingView() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController: self.navigationController)
        onboardingCoordinator.delegate = self
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showAuthScreen(userPreferences: UserPreferences? = nil, routines: [RoutineBlock]? = nil) {
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
        let aiGenerationCoordinator = AICoordinator(navigationController: self.navigationController)
        aiGenerationCoordinator.delegate = self
        addChild(aiGenerationCoordinator)
        aiGenerationCoordinator.showAIGeneration(with: userPreferences)
    }
    
    func showMainFlow() {
        let homeCoordinator = HomeCoordinator(navigationController: self.navigationController)
        addChild(homeCoordinator)
        
        if let routines = DependencyContainer.shared.routines {
            homeCoordinator.showHomeView(with: routines)
        } else {
            homeCoordinator.start()
        }
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
    func didCompleteSignIn(_ coordinator: AuthCoordinator, with user: User) {
        DependencyContainer.shared.saveData(user: user)
        removeChild(coordinator)
        showMainFlow()
    }
    
    func didCompleteSignUp(_ coordinator: AuthCoordinator, with user: User, routines: [RoutineBlock]) {
        DependencyContainer.shared.saveData(routines: routines, user: user)
        removeChild(coordinator)
        showMainFlow()
    }
    
    func didCancelAuth(_ coordinator: AuthCoordinator) {
        removeChild(coordinator)
    }
    
}

// MARK: - AI Generation Coordinator Delegate
extension AppCoordinator: AIGenerationCoordinatorDelegate {
    func didRequestSignUp(_ coordinator: AICoordinator, with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        showAuthScreen(userPreferences: userPreferences, routines: routines)
    }
}
