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
        
        handleAuthState()
        
        Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.handleAuthState()
        }
    }
    
    private func handleAuthState() {
        if Auth.auth().currentUser != nil {
            if navigationController.viewControllers.isEmpty {
                showMainFlow()
            }
        } else if DependencyContainer.shared.hasCompletedOnboarding {
            if navigationController.viewControllers.isEmpty {
                showOnboardingView()
            }
        } else {
            if navigationController.viewControllers.isEmpty {
                showOnboardingView()
            }
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
    
    func showMainFlow(isSignIn: Bool = false) {
        DependencyContainer.shared.loadCachedData()
        
        if isSignIn {
            Task { @MainActor in
                await DependencyContainer.shared.syncWithFirebaseAndWait()
                self.presentMainFlow()
            }
        } else {
            presentMainFlow()
            Task { @MainActor in
                await DependencyContainer.shared.syncWithFirebase()
            }
        }
    }
    
    private func presentMainFlow() {
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.delegate = self
        addChild(homeCoordinator)
        homeCoordinator.start()
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidRequestSignOut(_ coordinator: HomeCoordinator) {
        if let userId = DependencyContainer.shared.currentUser?.credentials.id {
            CoreDataManager.shared.deleteAllRoutines(forUserId: userId)
            CoreDataManager.shared.deleteUser(byId: userId)
        }
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
        DependencyContainer.shared.currentUser = user
        DependencyContainer.shared.routines = nil
        
        DependencyContainer.shared.markOnboardingCompleted()
        removeChild(coordinator)
        
        showMainFlow(isSignIn: true)
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
