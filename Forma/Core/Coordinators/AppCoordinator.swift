import UIKit
import FirebaseAuth

public final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let window: UIWindow
    
    init(window: UIWindow, navigationController: UINavigationController = UINavigationController()) {
        self.window = window
        self.navigationController = navigationController
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        DependencyContainer.shared.loadSavedData()
        
        if Auth.auth().currentUser != nil {
            showMainFlow()
        } else if DependencyContainer.shared.hasCompletedOnboarding {
            showOnboardingView()
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
        let aiGenerationCoordinator = AICoordinator(navigationController: navigationController)
        aiGenerationCoordinator.delegate = self
        addChild(aiGenerationCoordinator)
        aiGenerationCoordinator.showAIGeneration(with: userPreferences)
    }
    
    func showMainFlow() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.delegate = self
        addChild(homeCoordinator)
        
        if let routines = DependencyContainer.shared.routines {
            homeCoordinator.showHomeView(with: routines)
        } else {
            homeCoordinator.start()
        }
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidRequestSignOut(_ coordinator: HomeCoordinator) {
        DependencyContainer.shared.clearSession()
        removeChild(coordinator)
        navigationController.popToRootViewController(animated: false)
        showAuthScreen()
    }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func didTapSignIn(_ coordinator: OnboardingCoordinator) {
        showAuthScreen()
    }
    
    func didFinish(_ coordinator: OnboardingCoordinator, with userPreferences: UserPreferences) {
        DependencyContainer.shared.markOnboardingCompleted()
        removeChild(coordinator)
        showAIGeneration(with: userPreferences)
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func didCompleteSignIn(_ coordinator: AuthCoordinator, with user: User) {
        DependencyContainer.shared.saveData(user: user)
        DependencyContainer.shared.markOnboardingCompleted()
        removeChild(coordinator)
        showMainFlow()
    }
    
    func didCompleteSignUp(_ coordinator: AuthCoordinator, with user: User, routines: [RoutineBlock]) {
        DependencyContainer.shared.saveData(routines: routines, user: user)
        DependencyContainer.shared.markOnboardingCompleted()
        removeChild(coordinator)
        showMainFlow()
    }
    
    func didCancelAuth(_ coordinator: AuthCoordinator) {
        removeChild(coordinator)
    }
}

extension AppCoordinator: AIGenerationCoordinatorDelegate {
    func didRequestSignUp(_ coordinator: AICoordinator, with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        showAuthScreen(userPreferences: userPreferences, routines: routines)
    }
}
