import UIKit

protocol TrackerFormViewDelegate: AnyObject {
    func trackerFormView(_ view: TrackerFormView, didChangeTitle text: String)
    func trackerFormView(_ view: TrackerFormView, didSelectCategory optionView: TrackerOptionView)
    func trackerFormView(_ view: TrackerFormView, didSelectSchedule optionView: TrackerOptionView)
}

final class TrackerFormView: UIView {
    
    // MARK: - Delegate
    weak var delegate: TrackerFormViewDelegate?
    
    // MARK: - Private Properties
    private var formTitle: String
    private var formCategory: String
    private let emojis: [String]
    private let colors: [UIColor]
    private var formSchedule: [Schedule]
    private var bottomSpacerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Views
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var bottomSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleInputView, categoryOptionView, scheduleOptionView, bottomSpacerView])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleInputView: TrackerTitleInputView = {
        let view = TrackerTitleInputView()
        view.delegate = self
        return view
    }()
    
    private lazy var categoryOptionView: TrackerOptionView = {
        let view = TrackerOptionView()
        view.delegate = self
        return view
    }()
    
    private lazy var scheduleOptionView: TrackerOptionView = {
        let view = TrackerOptionView()
        view.delegate = self
        return view
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Initializer
    init(title: String, category: String, schedule: [Schedule], emojis: [String], colors: [UIColor]) {
        self.formTitle = title
        self.formCategory = category
        self.formSchedule = schedule
        self.emojis = emojis
        self.colors = colors
        super.init(frame: .zero)
        setupUI()
        updateDisplayedData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func updateSchedule(_ schedule: [Schedule]) {
        formSchedule = schedule
        updateDisplayedData()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(scrollView)
        setUpColorCollectionView()
        setUpEmojiCollectionView()
        scrollView.addSubview(contentStackView)
        setupConstraints()
    }
    
    private func setUpEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        emojiCollectionView.allowsMultipleSelection = false
        contentStackView.addArrangedSubview(emojiCollectionView)
    }
    
    private func setUpColorCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        colorCollectionView.allowsMultipleSelection = false
        contentStackView.addArrangedSubview(colorCollectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let heightConstraint = bottomSpacerView.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.isActive = true
        bottomSpacerHeightConstraint = heightConstraint
    }
    
    private func updateDisplayedData() {
        let categoryConfig = TrackerOptionConfiguration(
            title: "Категория",
            subtitle: formCategory,
            isFirst: true,
            isLast: false
        )
        categoryOptionView.configure(with: categoryConfig)
        
        let scheduleString = ScheduleHelper.formattedSchedule(from: formSchedule)
        let scheduleConfig = TrackerOptionConfiguration(
            title: "Расписание",
            subtitle: scheduleString,
            isFirst: false,
            isLast: true
        )
        scheduleOptionView.configure(with: scheduleConfig)
    }
}

// MARK: - TrackerTitleInputViewDelegate
extension TrackerFormView: TrackerTitleInputViewDelegate {
    func trackerTitleInputView(_ view: TrackerTitleInputView, didChangeText text: String) {
        delegate?.trackerFormView(self, didChangeTitle: text)
    }
}

// MARK: - TrackerOptionViewDelegate
extension TrackerFormView: TrackerOptionViewDelegate {
    func trackerOptionViewDidTap(_ view: TrackerOptionView) {
        if view === categoryOptionView {
            delegate?.trackerFormView(self, didSelectCategory: view)
        } else if view === scheduleOptionView {
            delegate?.trackerFormView(self, didSelectSchedule: view)
        }
    }
}

//MARK: - CollectionView
extension TrackerFormView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = emojis[indexPath.item]
            cell.configure(emoji: emoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = colors[indexPath.item]
            cell.configure(color: color)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            // при одиночном выборе достаточно, система сама снимет выделение со старой
        } else {
            // то же для цветов
        }
    }
    
}

