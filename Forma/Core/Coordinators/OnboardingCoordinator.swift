import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func didTapSignIn(_ coordinator: OnboardingCoordinator)
    func didFinish(_ coordinator: OnboardingCoordinator, with userPreferences: UserPreferences)
}

final class OnboardingCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: OnboardingCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
    
    func showEnergyPeakScreen() {
        let vc = EnergyPeakViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFocusBeginScreen(_ preferences: UserPreferences) {
        let vc = FocusBeginViewController()
        vc.userPreferences = preferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfessionalLifeScreen(_ preferences: UserPreferences) {
        let vc = ProfessionalLifeViewController()
        vc.userPreferences = preferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUltimateGoalScreen(_ preferences: UserPreferences) {
        let vc = UltimateGoalViewController()
        vc.userPreferences = preferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinishOnboarding(_ preferences: UserPreferences) {
        delegate?.didFinish(self, with: preferences)
    }
    
    func didTapSignIn() {
        delegate?.didTapSignIn(self)
    }
}
