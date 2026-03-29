//
//  HomeCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import UIKit
import SwiftUI

final class HomeCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHomeView()
    }
    
    func showHomeView(with routines: [RoutineBlock]? = nil) {
        let homeVC = UIHostingController(rootView: HomeView(routines: routines, coordinator: self))
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    func showRoutineDetails(_ routine: RoutineBlock) {
        let routineDetailsVC = UIHostingController(rootView: RoutineDetailView(routine: routine, onSave: { routine in
            // TODO: - Save routine func
        }))
        navigationController.pushViewController(routineDetailsVC, animated: true)
    }
}
