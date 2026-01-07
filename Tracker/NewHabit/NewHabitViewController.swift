import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Private Properties
    private var selectedScheduleDays: [Int] = []
    private var scheduleText: String = ""
    var onCreateTracker: ((Tracker, String) -> Void)?

    private var formTitle: String = ""
    private var formCategory: String = ""
    private var formSchedule: [Schedule] = []

    private let emojis = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪"]
    private let colorNames = (1...18).map { "Color\($0)" }
    private lazy var colors: [UIColor] = colorNames.compactMap { UIColor(named: $0) }

    private var formEmoji: String?
    private var formColor: UIColor?

    private var isEditMode: Bool = false
    private var editingTrackerId: UUID?
    private var completedDaysCount: Int = 0

    private var isFormReady: Bool {
        !formTitle.isEmpty && !formSchedule.isEmpty && !formCategory.isEmpty && formEmoji != nil && formColor != nil
    }
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlackIOS
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var formView: TrackerFormView = {
        let view = TrackerFormView(
            title: formTitle,
            category: formCategory,
            schedule: formSchedule,
            emojis: emojis,
            colors: colors
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("new_habit.cancel_button", comment: "Cancel button title"), for: .normal)
        button.setTitleColor(.ypRedIOS, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRedIOS).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGrayIOS
        button.setTitle(NSLocalizedString("new_habit.create_button", comment: "Create button title"), for: .normal)
        button.setTitleColor(.ypWhiteIOS, for: .normal)
        button.setTitleColor(.ypUniversalWhiteIOS, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteIOS

        let title = isEditMode ? NSLocalizedString("edit_habit.title", comment: "Edit habit title") : NSLocalizedString("new_habit.title", comment: "New habit title")
        navigationItem.title = title

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]

        view.addSubview(daysCountLabel)
        view.addSubview(formView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        let buttonTitle = isEditMode ? NSLocalizedString("edit_habit.save_button", comment: "Save button") : NSLocalizedString("new_habit.create_button", comment: "Create button title")
        createButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let formViewTopAnchor = isEditMode ? daysCountLabel.bottomAnchor : view.safeAreaLayoutGuide.topAnchor
        let formViewTopConstant: CGFloat = isEditMode ? 24 : 0

        NSLayoutConstraint.activate([
            daysCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            daysCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            formView.topAnchor.constraint(equalTo: formViewTopAnchor, constant: formViewTopConstant),
            formView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),

            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),

            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard !formTitle.isEmpty,
              !formCategory.isEmpty,
              let emoji = formEmoji,
              let color = formColor else { return }

        let trackerId = isEditMode ? (editingTrackerId ?? UUID()) : UUID()

        let tracker = Tracker(
            id: trackerId,
            title: formTitle,
            color: color,
            emoji: emoji,
            schedule: formSchedule
        )

        onCreateTracker?(tracker, formCategory)
        dismiss(animated: true)
    }
    
    private func updateCreateButtonState() {
        createButton.isEnabled = isFormReady
        createButton.backgroundColor = isFormReady ? .ypBlackIOS : .ypGrayIOS
    }

    // MARK: - Public Methods
    func configureForEditing(tracker: Tracker, categoryTitle: String, completedDaysCount: Int) {
        isEditMode = true
        editingTrackerId = tracker.id
        self.completedDaysCount = completedDaysCount

        formTitle = tracker.title
        formCategory = categoryTitle
        formEmoji = tracker.emoji
        formColor = tracker.color
        formSchedule = tracker.schedule

        daysCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("days_count", comment: ""), completedDaysCount)
        daysCountLabel.isHidden = false
    }
}

// MARK: - Extensions
extension NewHabitViewController: TrackerFormViewDelegate {
    func trackerFormView(_ view: TrackerFormView, didChangeTitle text: String) {
        formTitle = text
        updateCreateButtonState()
    }

    func trackerFormView(_ view: TrackerFormView, didSelectCategory optionView: TrackerOptionView) {
        let viewModel = CategoryViewModel(selectedCategory: formCategory)
        let categoryVC = CategoryViewController(viewModel: viewModel)

        categoryVC.onCategorySelected = { [weak self] selectedCategory in
            guard let self = self else { return }
            self.formCategory = selectedCategory
            self.formView.updateCategory(selectedCategory)
            self.updateCreateButtonState()
        }

        navigationController?.pushViewController(categoryVC, animated: true)
    }

    func trackerFormView(_ view: TrackerFormView, didSelectSchedule optionView: TrackerOptionView) {
        let scheduleVC = ScheduleViewController()
        let scheduleIndices = Set(formSchedule.map { $0.weekday })
        scheduleVC.selectedDays = scheduleIndices

        scheduleVC.onScheduleSelected = { [weak self] selectedDays, scheduleText in
            guard let self = self else { return }
            self.selectedScheduleDays = selectedDays
            self.scheduleText = scheduleText

            self.formSchedule = selectedDays.map { Schedule(weekday: $0) }
            self.formView.updateSchedule(self.formSchedule)
            self.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }

    func trackerFormView(_ view: TrackerFormView, didSelectEmoji emoji: String) {
        formEmoji = emoji
        updateCreateButtonState()
    }

    func trackerFormView(_ view: TrackerFormView, didSelectColor color: UIColor) {
        formColor = color
        updateCreateButtonState()
    }
}
