import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        let shownOnboardingEarlier = UserDefaults.standard.bool(forKey: "shownOnboardingEarlier")
        if shownOnboardingEarlier {
            window.rootViewController = TabBarController()
        } else {
            window.rootViewController = OnboardingPageViewController(transitionStyle: .scroll,
                                                                     navigationOrientation: .horizontal)
        }
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataService.shared.saveContext()
    }
}
