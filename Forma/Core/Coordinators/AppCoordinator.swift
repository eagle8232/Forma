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
        print("[Auth] showAuthScreen called")
        print("[Auth] Nav controller: \(navigationController)")
        print("[Auth] Nav controller VCs: \(navigationController.viewControllers.map { String(describing: type(of: $0)) })")
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        addChild(authCoordinator)
        print("[Auth] AuthCoordinator created and added. Child count: \(childCoordinators.count)")
        
        if let userPreferences, let routines {
            authCoordinator.showSignUpScreen(with: userPreferences, routines: routines)
        } else {
            authCoordinator.start()
        }
        print("[Auth] Auth flow started. VC count: \(navigationController.viewControllers.count)")
    }
    
    func showAIGeneration(with userPreferences: UserPreferences) {
        print("[AI] showAIGeneration called with preferences: \(userPreferences)")
        print("[AI] Nav controller: \(navigationController)")
        print("[AI] Nav VCs before: \(navigationController.viewControllers.map { String(describing: type(of: $0)) })")
        
        let aiGenerationCoordinator = AICoordinator(navigationController: navigationController)
        aiGenerationCoordinator.delegate = self
        addChild(aiGenerationCoordinator)
        aiGenerationCoordinator.showAIGeneration(with: userPreferences)
        
        print("[AI] Nav VCs after: \(navigationController.viewControllers.map { String(describing: type(of: $0)) })")
    }
    
    func showMainFlow(isSignIn: Bool = false) {
        DependencyContainer.shared.loadCachedData()
        
        let homeCoordinator = HomeCoordinator(navigationController: navigationController)
        homeCoordinator.delegate = self
        addChild(homeCoordinator)
        
        if isSignIn {
            homeCoordinator.showHomeView(with: DependencyContainer.shared.routines)
            Task {
                await DependencyContainer.shared.syncWithFirebaseAndWait()
                await MainActor.run {
                    homeCoordinator.clearAndShowHomeView(with: DependencyContainer.shared.routines)
                }
            }
        } else {
            homeCoordinator.startWithCachedData()
            Task {
                await DependencyContainer.shared.syncWithFirebase()
            }
        }
    }
}

extension AppCoordinator: HomeCoordinatorDelegate {
    func homeCoordinatorDidRequestSignOut(_ coordinator: HomeCoordinator) {
        CoreDataManager.shared.clearAllData()
        
        DependencyContainer.shared.clearSession()
        
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error)")
        }
        
        removeChild(coordinator)
        
        let newNavController = UINavigationController()
        navigationController = newNavController
        let onboardingCoordinator = OnboardingCoordinator(navigationController: newNavController)
        onboardingCoordinator.delegate = self
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
        
        window.rootViewController = newNavController
    }
}

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func didTapSignIn(_ coordinator: OnboardingCoordinator) {
        print("[Auth] didTapSignIn called")
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
