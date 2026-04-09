import UIKit

protocol OnboardingCoordinatorDelegate: AnyObject {
    func didTapSignIn(_ coordinator: OnboardingCoordinator)
    func didFinish(_ coordinator: OnboardingCoordinator, with userPreferences: UserPreferences)
}

final class OnboardingCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: OnboardingCoordinatorDelegate?
    
    private var userPreferences = UserPreferences(
        profession: "",
        sleepTime: DateHelper.today(at: 23, min: 0),
        wakeUpTime: DateHelper.today(at: 7, min: 0),
        focusTime: DateHelper.today(at: 9, min: 30),
        goal: []
    )
    
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
        vc.userPreferences = userPreferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFocusBeginScreen(_ preferences: UserPreferences) {
        userPreferences = preferences
        let vc = FocusBeginViewController()
        vc.userPreferences = userPreferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfessionalLifeScreen(_ preferences: UserPreferences) {
        userPreferences = preferences
        let vc = ProfessionalLifeViewController()
        vc.userPreferences = userPreferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showUltimateGoalScreen(_ preferences: UserPreferences) {
        userPreferences = preferences
        let vc = UltimateGoalViewController()
        vc.userPreferences = userPreferences
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didFinishOnboarding(_ preferences: UserPreferences) {
        userPreferences = preferences
        delegate?.didFinish(self, with: preferences)
    }
    
    func didTapSignIn() {
        print("[OnboardingCoordinator] didTapSignIn called")
        delegate?.didTapSignIn(self)
    }
}
