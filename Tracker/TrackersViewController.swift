import UIKit

final class TrackersViewController: UIViewController {
    //MARK: - UI elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .plusButton),
            target: TrackersViewController.self,
            action: nil
        )
        button.tintColor = UIColor(resource: .ypBlackIOS)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .stub))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(resource: .ypLightGrayIOS)
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: [.foregroundColor: UIColor(resource: .ypGrayIOS)]
        )
        
        let searchIcon = UIImage(resource: .mangnifyingglass)
        let imageView = UIImageView(image: searchIcon)
        imageView.tintColor = UIColor(resource: .ypGrayIOS)
        imageView.contentMode = .scaleAspectFit
        
        let containerView = UIView()
        containerView.addSubview(imageView)
        containerView.frame = CGRect(x: 0, y: 0, width: 28, height: 36)
        imageView.frame = CGRect(x: 8, y: 10, width: 15.63, height: 15.78)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let currentDate = formatter.string(from: Date())
        
        button.setTitle(currentDate, for: .normal)
        button.setTitleColor(.ypBlackIOS, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        setUpView()
        setUpConstraints()
    }
    
    //MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    //MARK: - Private methods
    private func setUpNavigationBar() {
        
        let dateBarButtonItem = UIBarButtonItem(customView: dateButton)
        let plusBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusBarButtonItem
        navigationItem.rightBarButtonItem = dateBarButtonItem
        
        navigationItem.titleView = searchTextField
        
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NSLayoutConstraint.activate([
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)
        
        view.addSubview(stubImage)
        view.addSubview(stubTitleLabel)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stubImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 147),
            stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            
            stubTitleLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stubTitleLabel.widthAnchor.constraint(equalToConstant: 343),
        ])
    }
}
