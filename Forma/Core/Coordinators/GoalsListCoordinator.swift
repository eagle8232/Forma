//
//  GoalsListCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import UIKit
import SwiftUI

final class GoalsListCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let goalsListVC = UIHostingController(rootView: GoalsListView(coordinator: self))
        navigationController.setViewControllers([goalsListVC], animated: true)
    }
    
    func showGoalDetails(_ goal: Goal) {
        let goalDetailsVC = UIHostingController(rootView: GoalDetailView(goal: goal))
        navigationController.pushViewController(goalDetailsVC, animated: true)
    }
}
