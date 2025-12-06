import UIKit

final class NewHabitViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedScheduleDays: [Int] = []
    private var scheduleText: String = ""
    var onCreateTracker: ((Tracker) -> Void)?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypGrayIOS]
        )
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRedIOS
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGrayIOS.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(optionsTableView)
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
        
        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupConstraints() {
        tableViewTopConstraint = optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
            
            tableViewTopConstraint!,
            optionsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            optionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
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
        let hasTitle = !(titleTextField.text?.isEmpty ?? true)
        let hasSchedule = !selectedScheduleDays.isEmpty
        
        createButton.isEnabled = hasTitle && hasSchedule
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
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let schedule = selectedScheduleDays.map { Schedule(weekday: $0) }
        let tracker = Tracker(
            id: UUID(),
            title: title,
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
        errorLabel.isHidden = !show
        tableViewTopConstraint?.constant = show ? 38 : 24
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        showError(false)
        return true
    }
}
