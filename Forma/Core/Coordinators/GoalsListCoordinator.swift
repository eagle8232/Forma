import UIKit
import SwiftUI

final class GoalsListCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = FormaHostingController(rootView: GoalsListView(coordinator: self))
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func showGoalDetails(_ goal: Goal) {
        let vc = FormaHostingController(rootView: GoalDetailView(goal: goal))
        navigationController.pushViewController(vc, animated: true)
    }
}
