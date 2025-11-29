import UIKit

final class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController = TrackersViewController()
        self.viewControllers = [viewController]
    }
}
