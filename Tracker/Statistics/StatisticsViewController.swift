import UIKit

final class StatisticsViewController: UIViewController {

    //MARK: - Properties
    private let statisticsService = StatisticsService.shared

    private var finishedTrackersCount: Int = 0 {
        didSet {
            updateUI()
        }
    }

    //MARK: - UI Elements
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let finishedTrackersCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let finishedTrackersCommentLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.finished_trackers_label", comment: "Finished trackers message")
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        statisticsService.delegate = self
        loadStatistics()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
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
        view.addSubview(cardView)

        cardView.addSubview(finishedTrackersCountLabel)
        cardView.addSubview(finishedTrackersCommentLabel)

        setupGradientBorder()
    }

    private func setupGradientBorder() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 90)
        gradientLayer.colors = [
            UIColor(red: 0, green: 123/255, blue: 250/255, alpha: 1).cgColor,
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor,
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor   
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.cornerRadius = 16

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.path = UIBezierPath(roundedRect: gradientLayer.bounds, cornerRadius: 16).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        cardView.layer.addSublayer(gradientLayer)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statisticsStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            statisticsStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            statisticsStubImage.widthAnchor.constraint(equalToConstant: 80),
            statisticsStubImage.heightAnchor.constraint(equalToConstant: 80),
            
            statisticsStubTitleLabel.topAnchor.constraint(equalTo: statisticsStubImage.bottomAnchor, constant: 8),
            statisticsStubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            finishedTrackersCountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            finishedTrackersCountLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            finishedTrackersCommentLabel.topAnchor.constraint(equalTo: finishedTrackersCountLabel.bottomAnchor, constant: 7),
            finishedTrackersCommentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
    }

    private func updateUI() {
        finishedTrackersCountLabel.text = "\(finishedTrackersCount)"

        let hasFinishedTrackers = finishedTrackersCount > 0

        cardView.isHidden = !hasFinishedTrackers
        statisticsStubImage.isHidden = hasFinishedTrackers
        statisticsStubTitleLabel.isHidden = hasFinishedTrackers
    }

    private func loadStatistics() {
        finishedTrackersCount = statisticsService.getFinishedTrackersCount()
    }

}

// MARK: - StatisticsServiceDelegate
extension StatisticsViewController: StatisticsServiceDelegate {
    func statisticsDidUpdate() {
        loadStatistics()
    }
}

