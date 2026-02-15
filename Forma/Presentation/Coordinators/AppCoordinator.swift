//
//  AppCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

public final class AppCoordinator: Coordinator {
    
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
    }
    
    func showOnboardingView() {
        let onboardingVC = OnboardingViewController()
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
    
    func showAuthFlow() {
        
    }
    
    func showMainFlow() {
        // This is called when Auth is successful
    }
}
