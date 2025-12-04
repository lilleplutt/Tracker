import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI elements
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhiteIOS
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackIOS
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .ypBlackIOS
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Properties
    private var trackerId: UUID?
    private var isCompleted = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        contentView.addSubview(colorView)
        colorView.addSubview(emojiLabel)
        colorView.addSubview(titleLabel)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(plusButton)
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Цветная верхняя часть
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            // Эмодзи
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Название
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            // Счетчик дней
            daysCountLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // Кнопка
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc private func plusButtonTapped() {
            isCompleted.toggle()
            updatePlusButton()
            
            // Здесь позже будем обновлять счетчик дней
        }
        
        private func updatePlusButton() {
            if isCompleted {
                plusButton.setTitle("✓", for: .normal)
                plusButton.backgroundColor = colorView.backgroundColor?.withAlphaComponent(0.3)
                plusButton.tintColor = .white
            } else {
                plusButton.setTitle("+", for: .normal)
                plusButton.backgroundColor = .ypBlackIOS
                plusButton.tintColor = .white
            }
        }
    
    private func updateDaysCount(_ count: Int) {
            let daysString: String
            
            switch count {
            case 1:
                daysString = "1 день"
            case 2...4:
                daysString = "\(count) дня"
            default:
                daysString = "\(count) дней"
            }
            
            daysCountLabel.text = daysString
        }
    
    // MARK: - Public methods
    func configure(with tracker: Tracker) {
        trackerId = tracker.id
                
                // Устанавливаем цвет
                colorView.backgroundColor = tracker.color
                
                // Устанавливаем эмодзи
                emojiLabel.text = tracker.emoji
                
                // Устанавливаем название
                titleLabel.text = tracker.title
                
                // Устанавливаем счетчик дней
                updateDaysCount(completedDays)
                
                // Обновляем кнопку
                updatePlusButton()
    }
}

