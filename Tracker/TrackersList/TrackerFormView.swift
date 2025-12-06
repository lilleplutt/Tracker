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
    
    private var trackerState: NewTrackerState
    
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
    
    // MARK: - Initializer
    
    init(initialState: NewTrackerState) {
        self.trackerState = initialState
        super.init(frame: .zero)
        setupUI()
        updateDisplayedData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateState(_ newState: NewTrackerState) {
        trackerState = newState
        updateDisplayedData()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        setupConstraints()
    }
    
    private var bottomSpacerHeightConstraint: NSLayoutConstraint?
    
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
        
        // Устанавливаем высоту спейсера, чтобы контент всегда был скроллируемым
        let heightConstraint = bottomSpacerView.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.isActive = true
        bottomSpacerHeightConstraint = heightConstraint
    }
    
    private func updateDisplayedData() {
        let categoryConfig = TrackerOptionConfiguration(
            title: "Категория",
            subtitle: trackerState.category,
            isFirst: true,
            isLast: false
        )
        categoryOptionView.configure(with: categoryConfig)
        
        let scheduleString = Weekday.formattedWeekdays(Array(trackerState.schedule))
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

