import UIKit
import SwiftUI
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        showIntro(on: window)
        
        applySavedAppearance()
        
        if let urlContext = connectionOptions.urlContexts.first {
            GIDSignIn.sharedInstance.handle(urlContext.url)
        }
    }

    private func showIntro(on window: UIWindow) {
        let introView = IntroView { [weak self] answers in
            guard let self = self else { return }
            DependencyContainer.shared.saveIntroAnswers(answers)
            self.transitionToMainApp(window: window)
        }
        let hostingController = UIHostingController(rootView: introView)
        hostingController.view.backgroundColor = UIColor.black
        
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
    }

    private func transitionToMainApp(window: UIWindow) {
        let navigationController = UINavigationController()
        self.appCoordinator = AppCoordinator(window: window, navigationController: navigationController)
        
        window.rootViewController = navigationController
        self.appCoordinator?.start()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {
        applySavedAppearance()
    }
    func sceneDidEnterBackground(_ scene: UIScene) {}
    
    private func applySavedAppearance() {
        guard let user = DependencyContainer.shared.currentUser,
              let appearanceMode = user.preferences?.appearanceMode,
              let mode = AppearanceMode(rawValue: appearanceMode),
              let window = window else { return }
        
        switch mode {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .light:
            window.overrideUserInterfaceStyle = .light
        }
    }
}
