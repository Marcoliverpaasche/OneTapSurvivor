import UIKit
import GameKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AdManager.shared.initializeSDK()
        authenticateGameCenter()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .portrait
    }

    private func authenticateGameCenter() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let error {
                print("[GameCenter] Auth-Fehler: \(error.localizedDescription)")
                return
            }
            if let viewController {
                DispatchQueue.main.async {
                    self?.topViewController()?.present(viewController, animated: true)
                }
            } else if GKLocalPlayer.local.isAuthenticated {
                print("[GameCenter] Eingeloggt als: \(GKLocalPlayer.local.displayName)")
            }
        }
    }

    private func topViewController() -> UIViewController? {
        let keyWindow = window ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        return keyWindow?.rootViewController
    }
}
