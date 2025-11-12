import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "", //add title from figma
            image: UIImage(resource: .tabBarTracker),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "", //add title from figma
            image: UIImage(resource: .tabBarStatistics),
            selectedImage: nil)
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
}
