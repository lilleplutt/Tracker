import UIKit

struct NewTrackerState {
    var title: String
    var category: String
    var schedule: Set<Weekday>
    var emoji: String
    var color: UIColor?
    
    var isReady: Bool {
        !title.isEmpty &&
        !schedule.isEmpty //&&
        //!category.isEmpty &&
        //!emoji.isEmpty &&
        //color != nil
    }
}

protocol NewTrackerViewControllerDelegate: AnyObject {
    func createTracker(from config: NewTrackerState)
}

enum Weekday: Int, CaseIterable {
    
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortString: String {
        switch self {
        case .sunday: return "Вс"
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        }
    }
    
    var longString: String {
        switch self {
        case .sunday: return "Воскресенье"
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        }
    }
    
    static let ordered: [Weekday] = [
        .monday,
        .tuesday,
        .wednesday,
        .thursday,
        .friday,
        .saturday,
        .sunday
    ]
    
    static func formattedWeekdays(_ days: [Weekday]) -> String {
        guard !days.isEmpty else { return "" }
        guard !(days.count == allCases.count) else { return "Каждый день" }
        
        let orderedDays = ordered.filter { days.contains($0) }
        let orderedDaysString = orderedDays.map { $0.shortString }.joined(separator: ", ")
        return orderedDaysString
    }
    
}



final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedScheduleDays: [Int] = []
    private var scheduleText: String = ""
    var onCreateTracker: ((Tracker) -> Void)?
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private var state = NewTrackerState(
        title: "",
        category: "Важное",
        schedule: [],
        emoji: "🤯",
        color: .ypRedIOS
    ) {
        didSet {
            createButton.isEnabled = state.isReady
            createButton.backgroundColor = state.isReady ? .ypBlackIOS : .ypGrayIOS
            formTableView.updateState(state)
        }
    }
    
    private lazy var formTableView: TrackerFormTableView = {
        let tableView = TrackerFormTableView(initialState: state)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
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
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhiteIOS, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteIOS
        navigationItem.title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]

        view.addSubview(formTableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            formTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            formTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            formTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            formTableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
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
        guard !state.title.isEmpty else { return }
        
        // Convert Weekday (1-7) to Schedule weekday format
        let schedule = state.schedule.map { weekday -> Schedule in
            Schedule(weekday: weekday.rawValue)
        }
        
        let tracker = Tracker(
            id: UUID(),
            title: state.title,
            color: state.color ?? .ypBlueIOS,
            emoji: state.emoji,
            schedule: schedule
        )
        
        onCreateTracker?(tracker)
        dismiss(animated: true)
    }
}

// MARK: - Extensions
extension NewHabitViewController: TrackerFormTableViewDelegate {
    func trackerFormTableView(_ tableView: TrackerFormTableView, didChangeTitle text: String) {
        state.title = text
    }
    
    func trackerFormTableView(_ tableView: TrackerFormTableView, didSelectCategoryAt indexPath: IndexPath) {
        print("Категория tapped")
    }
    
    func trackerFormTableView(_ tableView: TrackerFormTableView, didSelectScheduleAt indexPath: IndexPath) {
        let scheduleVC = ScheduleViewController()
        // Convert Weekday (1-7, where 1=Sunday) to ScheduleViewController indices (0-6, where 0=Monday)
        let scheduleIndices = state.schedule.map { weekday -> Int in
            // 1 (Sunday) -> 6, 2 (Monday) -> 0, 3 (Tuesday) -> 1, ..., 7 (Saturday) -> 5
            return weekday.rawValue == 1 ? 6 : weekday.rawValue - 2
        }
        scheduleVC.selectedDays = Set(scheduleIndices)
        
            scheduleVC.onScheduleSelected = { [weak self] selectedDays, scheduleText in
                guard let self = self else { return }
                self.selectedScheduleDays = selectedDays
                self.scheduleText = scheduleText
                
                // Map ScheduleViewController indices (0-6, where 0=Monday) to Weekday (1-7, where 1=Sunday)
                let weekdays = Set(selectedDays.map { index -> Weekday? in
                    // 0 (Monday) -> 2, 1 (Tuesday) -> 3, ..., 5 (Saturday) -> 7, 6 (Sunday) -> 1
                    let weekdayValue = index == 6 ? 1 : index + 2
                    return Weekday(rawValue: weekdayValue)
                }.compactMap { $0 })
                self.state.schedule = weekdays
                self.formTableView.reloadScheduleRow()
            }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    func trackerFormTableViewDidRequestLayoutUpdate(_ tableView: TrackerFormTableView) {
        // Layout updates are handled automatically by the table view
    }
}
