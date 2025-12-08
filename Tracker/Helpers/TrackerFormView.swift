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
    init(title: String, category: String, schedule: [Schedule]) {
        self.formTitle = title
        self.formCategory = category
        self.formSchedule = schedule
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
        scrollView.addSubview(contentStackView)
        setupConstraints()
    }
    
    private func setUpEmojiCollectionView() {
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        contentStackView.addArrangedSubview(emojiCollectionView)
    }
    
    private func setUpCmojiCollectionView() {
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
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
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
}

