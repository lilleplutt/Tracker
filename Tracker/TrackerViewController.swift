import UIKit

final class TrackerViewController: UIViewController {
    //MARK: - UI elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .plusButton),
            target: TrackerViewController.self,
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Поиск"
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(resource: .ypGrayIOS)
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let searchIcon = UIImage(resource: .mangnifyingglass)
        textField.leftViewMode = .always
        textField.leftView = UIImageView(image: searchIcon)
        textField.leftView?.tintColor = UIColor(resource: .ypGrayIOS)
        textField.leftView?.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        (textField.leftView as? UIImageView)?.contentMode = .scaleAspectFit
        return textField
    }()
    
    private let dateButton: UIButton = {
        let button = UIButton()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.mm.yy"
        let currentDate = formatter.string(from: Date())
        
        button.setTitle(currentDate, for: .normal)
        button.tintColor = UIColor(resource: .ypBlackIOS)
        button.backgroundColor = UIColor(resource: .ypGrayIOS)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpConstraints()
    }
    
    //MARK: - Private methods
    private func setUpView() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)
    }
    
    private func setUpConstraints() {
        
    }
}


