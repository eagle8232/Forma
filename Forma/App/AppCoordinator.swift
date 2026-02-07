//
//  AppCoordinator.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import UIKit

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
        
//        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
//            showMainFlow()
//        } else {
//            showOnboardingView()
//        }
        showMainFlow()
    }
    
    func showOnboardingView() {
        print("false")
    }
    
    func showAuthFlow() {
        
    }
    
    func showMainFlow() {
        // This is called when Auth is successful
        let homeVC = ViewController() // - This is an example view controller
        navigationController.setViewControllers([homeVC], animated: true)
    }
}
