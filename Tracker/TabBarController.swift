import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = TrackersViewController()
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.tabBarItem = UITabBarItem(
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
        
        self.viewControllers = [trackerNavigationController, statisticsViewController]
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
