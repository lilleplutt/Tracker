import UIKit

final class PageTwoViewController: UIViewController {
    
    //MARK: - UI Elements
    private lazy var onboardingImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .onboardingTwo))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var onboardingLabel: UILabel = {
        let label = UILabel()
        label.text = "Даже если это\nне литры воды и йога"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    //MARK: - Private Methods
    private func setupUI() {
        view.addSubview(onboardingImageView)
        view.addSubview(onboardingLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            onboardingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            onboardingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 476),
        ])
    }
}

