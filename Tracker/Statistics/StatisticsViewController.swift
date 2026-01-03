import UIKit

final class StatisticsViewController: UIViewController {
    
    //MARK: - UI Elements
    private let statisticsStubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .statisticsStub))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statisticsStubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.stub_message", comment: "Statistics list stub message")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
    }
    
    //MARK: - Private methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Statistics screen title")
        navigationItem.largeTitleDisplayMode = .always
        
        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = NSLocalizedString("statistics.title", comment: "Statistics screen large title")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)
        view.addSubview(statisticsStubImage)
        view.addSubview(statisticsStubTitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statisticsStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            statisticsStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticsStubImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsStubImage.heightAnchor.constraint(equalToConstant: 80),
            
            statisticsStubTitleLabel.topAnchor.constraint(equalTo: statisticsStubImage.bottomAnchor, constant: 8),
            statisticsStubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
}
