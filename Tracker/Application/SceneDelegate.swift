import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        setUpLaunchScreen()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showMainInterface()
        }
    }
    
    private func setUpLaunchScreen() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let launchViewController = UIViewController()
        launchViewController.view.backgroundColor = UIColor(named: "YP Blue iOS")
        
        let launchImageView = UIImageView(image: UIImage(named: "splash_logo_image"))
        launchImageView.translatesAutoresizingMaskIntoConstraints = false
        launchImageView.contentMode = .scaleAspectFit
        launchViewController.view.addSubview(launchImageView)
        
        launchImageView.centerXAnchor.constraint(equalTo: launchViewController.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        launchImageView.centerYAnchor.constraint(equalTo: launchViewController.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        window?.rootViewController = launchViewController
        window?.makeKeyAndVisible()
    }
    
    private func showMainInterface() {
        let mainViewController = ViewController()
        window?.rootViewController = mainViewController
    }
}

