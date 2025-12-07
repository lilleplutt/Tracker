import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteIOS
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = .emojiBackground
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quanityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackIOS
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Properties
    weak var delegate: TrackersCollectionViewCellDelegate?
    private var trackerId: UUID?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        contentView.addSubview(colorView)
        colorView.addSubview(emojiLabel)
        colorView.addSubview(titleLabel)
        contentView.addSubview(quanityLabel)
        contentView.addSubview(plusButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            quanityLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            quanityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupActions() {
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        delegate?.completeButtonDidTap(in: self)
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, isCompleted: Bool, quanity: Int) {
        trackerId = tracker.id
        colorView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        quanityLabel.text = getDayString(quanity)
        
        let plusImage = UIImage(resource: .addHabitButton).withRenderingMode(.alwaysTemplate)
        let doneImage = UIImage(resource: .completeHabitButton).withRenderingMode(.alwaysTemplate)
        
        if isCompleted {
            plusButton.setImage(doneImage, for: .normal)
            plusButton.backgroundColor = .ypWhiteIOS
            plusButton.tintColor = tracker.color
        } else {
            plusButton.setImage(plusImage, for: .normal)
            plusButton.backgroundColor = .ypWhiteIOS
            plusButton.tintColor = tracker.color
        }
    }
    
    private func getDayString(_ value: Int) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        
        let word: String = {
            switch (mod100, mod10) {
            case (11...14, _):
                return "дней"
            case (_, 1):
                return "день"
            case (_, 2...4):
                return "дня"
            default:
                return "дней"
            }
        }()
        
        return "\(value) \(word)"
    }
}
