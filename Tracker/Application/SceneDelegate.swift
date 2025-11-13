import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        setUpLaunchScreen()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainInterface()
        }
        
        window.makeKeyAndVisible()
    }
    
    private func setUpLaunchScreen() {
        let launchViewController = UIViewController()
        launchViewController.view.backgroundColor = UIColor(resource: .ypBlueIOS)
        
        let launchImageView = UIImageView(image: UIImage(resource: .splashLogo))
        launchImageView.translatesAutoresizingMaskIntoConstraints = false
        launchImageView.contentMode = .scaleAspectFit
        launchViewController.view.addSubview(launchImageView)
        
        NSLayoutConstraint.activate([
            launchImageView.centerXAnchor.constraint(equalTo: launchViewController.view.safeAreaLayoutGuide.centerXAnchor),
            launchImageView.centerYAnchor.constraint(equalTo: launchViewController.view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        window?.rootViewController = launchViewController
    }
    
    private func showMainInterface() {
        let mainViewController = TrackerViewController()
        window?.rootViewController = mainViewController
    }
}
