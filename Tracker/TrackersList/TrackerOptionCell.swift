import UIKit

struct TrackerOptionConfiguration {
    let title: String
    let subtitle: String
    let isFirst: Bool
    let isLast: Bool
}

final class TrackerOptionCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "TrackerOptionCellReuseIdentifier"
    
    // MARK: - Views
    
    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelsStackView, UIView(), chevronImageView])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundIOS
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlackIOS
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypGrayIOS
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .chevron
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGrayIOS
        return view
    }()
    
    // MARK: - Private Properties
    
    private var optionTitle: String = "" {
        didSet {
            titleLabel.text = optionTitle
        }
    }
    
    private var optionSubtitle: String = "" {
        didSet {
            subtitleLabel.text = optionSubtitle
            subtitleLabel.isHidden = optionSubtitle.isEmpty
        }
    }
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(mainStackView)
        backgroundContainerView.addSubview(separatorView)
        
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalTo: chevronImageView.widthAnchor),
            
            mainStackView.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
            
            backgroundContainerView.heightAnchor.constraint(equalToConstant: 75),
            backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with configuration: TrackerOptionConfiguration) {
        optionTitle = configuration.title
        optionSubtitle = configuration.subtitle
        
        if configuration.isFirst {
            backgroundContainerView.layer.cornerRadius = 16
            backgroundContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if configuration.isLast {
            backgroundContainerView.layer.cornerRadius = 16
            backgroundContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        }
    }
}

