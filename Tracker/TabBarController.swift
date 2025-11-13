import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTracker),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика", 
            image: UIImage(resource: .tabBarStatistics),
            selectedImage: nil)
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
}
