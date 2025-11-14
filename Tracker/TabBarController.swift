import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTracker).withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(resource: .tabBarTracker).withRenderingMode(.alwaysTemplate)
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStatistics).withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(resource: .tabBarStatistics).withRenderingMode(.alwaysTemplate)
        )
        
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
}
