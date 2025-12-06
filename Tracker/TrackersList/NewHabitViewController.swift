import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedScheduleDays: [Int] = []
    private var scheduleText: String = ""
    var onCreateTracker: ((Tracker) -> Void)?
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypWhiteIOS
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGrayIOS.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(EnterNameCell.self, forCellReuseIdentifier: EnterNameCell.reuseID)
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "optionCell")
        
        cell.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlackIOS
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .ypGrayIOS
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = "Важное"
        case 1:
            cell.textLabel?.text = "Расписание"
            if !selectedScheduleDays.isEmpty {
                cell.detailTextLabel?.text = scheduleText.isEmpty ?
                getScheduleText(from: selectedScheduleDays) : scheduleText
            } else {
                cell.detailTextLabel?.text = nil
            }
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        
        return cell
    }
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
