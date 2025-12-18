import UIKit

final class OnboardingViewController: UIPageViewController {
    
    lazy var pages: [UIViewController] = {
            let pageOne = UIViewController()
            pageOne.view.backgroundColor = .red
            
            let pageTwo = UIViewController()
            pageTwo.view.backgroundColor = .green
            
            return [pageOne, pageTwo]
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            if let first = pages.first {
                setViewControllers([first], direction: .forward, animated: true, completion: nil)
            }
        }
}
