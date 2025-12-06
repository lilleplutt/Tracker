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
    
    private enum SectionType: Int, CaseIterable {
        case enterName, parameters
    }
    
    private enum ParameterType: Int, CaseIterable {
        case category, schedule
    }
    
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
        }
    }
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(EnterNameCell.self, forCellReuseIdentifier: EnterNameCell.reuseID)
        tableView.register(ParameterCell.self, forCellReuseIdentifier: ParameterCell.reuseID)
        
        tableView.backgroundColor = .ypWhiteIOS

        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true

        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGrayIOS.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        return tableView
    }()
    
    private var tableViewTopConstraint = NSLayoutConstraint()
    
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
        setupTableView()
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

        view.addSubview(optionsTableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
    }
    
    private func setupTableView() {
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        optionsTableView.rowHeight = 75
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            optionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            optionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
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
    
    private func updateCreateButtonState() {
//        let hasTitle = !(titleTextField.text?.isEmpty ?? true)
//        let hasSchedule = !selectedScheduleDays.isEmpty
        
        createButton.isEnabled = true // hasTitle && hasSchedule
        createButton.backgroundColor = createButton.isEnabled ? .ypBlackIOS : .ypGrayIOS
    }
    
    private func getScheduleText(from days: [Int]) -> String {
        if days.count == 7 {
            return "Каждый день"
        } else {
            let daySymbols = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            let selectedDaySymbols = days.sorted().map { daySymbols[$0] }
            return selectedDaySymbols.joined(separator: ", ")
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        // guard let title = titleTextField.text, !title.isEmpty else { return }
        let schedule = selectedScheduleDays.map { Schedule(weekday: $0) }
        let tracker = Tracker(
            id: UUID(),
            title: "title",
            color: .ypBlueIOS,
            emoji: "🏃‍♂️",
            schedule: schedule
        )
        
        onCreateTracker?(tracker)
        dismiss(animated: true)
    }
}

// MARK: - Extensions
extension NewHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else {
            return 0
        }
        switch sectionType {
        case .enterName: return 1
        case .parameters: return ParameterType.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .enterName:
            return makeEnterNameCell(tableView, for: indexPath)
        case .parameters:
            return makeParameterCell(tableView, for: indexPath)
        }
    }
    
    private func makeEnterNameCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EnterNameCell.reuseID, for: indexPath) as? EnterNameCell else {
            assertionFailure("❌[makeEnterNameCell]: can't dequeue reusable cell with id: \(EnterNameCell.reuseID) as \(String(describing: EnterNameCell.self))")
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
    
    private func makeParameterCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let parameterType = ParameterType(rawValue: indexPath.row) else {
            assertionFailure("❌[makeParameterCell] no such rawValue for \(String(describing: ParameterType.self))")
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ParameterCell.reuseID, for: indexPath) as? ParameterCell else {
            assertionFailure("❌[makeParameterCell]: can't dequeue reusable cell with id: \(ParameterCell.reuseID) as \(String(describing: ParameterCell.self))")
            return UITableViewCell()
        }
        
        let configuration = parameterConfig(type: parameterType)
        cell.configure(parameter: configuration)
        return cell
    }
    
    private func parameterConfig(type: ParameterType) -> NewTrackerParameter {
        switch type {
        case .category:
            return NewTrackerParameter(title: "Категория", subtitle: state.category, isFirst: true, isLast: false)
        case .schedule:
            let scheduleString = Weekday.formattedWeekdays(Array(state.schedule))
            return NewTrackerParameter(title: "Расписание", subtitle: scheduleString, isFirst: false, isLast: true)
        }
    }
}

struct NewTrackerParameter {
    let title: String
    let subtitle: String
    let isFirst: Bool
    let isLast: Bool
}

extension NewHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("Категория tapped")
        case 1:
            let scheduleVC = ScheduleViewController()
            scheduleVC.selectedDays = Set(selectedScheduleDays)
            
            scheduleVC.onScheduleSelected = { [weak self] selectedDays, scheduleText in
                self?.selectedScheduleDays = selectedDays
                self?.scheduleText = scheduleText
                self?.optionsTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
                self?.updateCreateButtonState()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        default:
            break
        }
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count > 38 {
            showError(true)
            return false
        } else {
            showError(false)
            return true
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateCreateButtonState()
        let text = textField.text ?? ""
        if text.count > 38 {
            showError(true)
        } else {
            showError(false)
        }
    }
    
    private func showError(_ show: Bool) {
        // errorLabel.isHidden = !show
        tableViewTopConstraint.constant = show ? 38 : 24
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        showError(false)
        return true
    }
}

extension NewHabitViewController: EnterNameCellDelegate {
    
    func enterNameCell(_ cell: EnterNameCell, didChangeText text: String) {
        state.title = text
    }
    
    func updateCellLayout() {
        optionsTableView.beginUpdates()
        optionsTableView.endUpdates()
    }
}
