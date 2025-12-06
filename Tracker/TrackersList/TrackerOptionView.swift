import UIKit

protocol TrackerOptionViewDelegate: AnyObject {
    func trackerOptionViewDidTap(_ view: TrackerOptionView)
}

struct TrackerOptionConfiguration {
    let title: String
    let subtitle: String
    let isFirst: Bool
    let isLast: Bool
}

final class TrackerOptionView: UIView {
    
    // MARK: - Delegate
    
    weak var delegate: TrackerOptionViewDelegate?
    
    // MARK: - Views
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelsStackView, UIView(), chevronImageView])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundIOS
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlackIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGrayIOS
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGrayIOS
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(mainStackView)
        backgroundContainerView.addSubview(separatorView)
        
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalTo: chevronImageView.widthAnchor),
            
            mainStackView.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
            
            backgroundContainerView.heightAnchor.constraint(equalToConstant: 75),
            backgroundContainerView.topAnchor.constraint(equalTo: topAnchor),
            backgroundContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backgroundContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backgroundContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func didTap() {
        delegate?.trackerOptionViewDidTap(self)
    }
    
    // MARK: - Public Methods
    
    func configure(with configuration: TrackerOptionConfiguration) {
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        subtitleLabel.isHidden = configuration.subtitle.isEmpty
        
        if configuration.isFirst {
            backgroundContainerView.layer.cornerRadius = 16
            backgroundContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if configuration.isLast {
            backgroundContainerView.layer.cornerRadius = 16
            backgroundContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        } else {
            separatorView.isHidden = false
        }
    }
}

