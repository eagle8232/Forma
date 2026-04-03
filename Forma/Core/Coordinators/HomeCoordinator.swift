import UIKit
import SwiftUI

protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinatorDidRequestSignOut(_ coordinator: HomeCoordinator)
}

final class HomeCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: HomeCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showHomeView()
    }
    
    func showHomeView(with routines: [RoutineBlock]? = nil) {
        let homeVC = FormaHostingController(rootView: HomeView(routines: routines, coordinator: self))
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    func showRoutineDetails(_ routine: RoutineBlock) {
        let vc = FormaHostingController(rootView: RoutineDetailView(routine: routine, onSave: { _ in }))
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfileView(user: User) {
        let profileView = ProfileView(
            user: user,
            authRepository: AuthRepository(),
            onSignOut: { [weak self] in
                self?.signOut()
            },
            onEditProfile: { }
        )
        
        let vc = FormaHostingController(rootView: profileView)
        vc.view.backgroundColor = UIColor(AppColor.background)
        vc.title = "Profile"
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func signOut() {
        delegate?.homeCoordinatorDidRequestSignOut(self)
    }
}
