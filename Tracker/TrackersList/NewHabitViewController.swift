import UIKit

final class NewHabitViewController: UIViewController {
    
    //MARK: - UI elements
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите название трекера"
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchController
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRedIOS, for: .normal) //add red color
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpConstraints()
    }
    
    //MARK: - Private properties
    private func setUpView() {
        view.backgroundColor = .ypWhiteIOS
        navigationItem.title = "Новая привычка"
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
        searchController.searchBar.widthAnchor.constraint(equalToConstant: 343),
        searchController.searchBar.heightAnchor.constraint(equalToConstant: 75),
        searchController.searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 138),
        searchController.searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
        
        
    
}

