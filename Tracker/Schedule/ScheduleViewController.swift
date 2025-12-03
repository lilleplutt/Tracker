import UIKit

final class ScheduleViewController: UIViewController {
    
    //MARK: - UI elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor.ypGrayIOS.withAlphaComponent(0.3) //new
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypWhiteIOS, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackIOS
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private properties
    private let weekDays = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    // MARK: - Public properties
    var selectedDays: Set<Int> = []
    var onScheduleSelected: (([Int]) -> Void)?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpConstraints()
        setupTableView()
        setupReadyButton()
    }
    
    //MARK: - Private methods
    private func setUpView() {
        view.backgroundColor = .ypWhiteIOS
        navigationItem.title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        view.addSubview(readyButton)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude)) // Фиксируем пустое место
    }
    
    private func setupReadyButton() {
        readyButton.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -24),
            
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Actions
    @objc private func didTapReadyButton() {
        onScheduleSelected?(Array(selectedDays).sorted())
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let dayIndex = sender.tag
        
        if sender.isOn {
            selectedDays.insert(dayIndex)
        } else {
            selectedDays.remove(dayIndex)
        }
    }
}

// MARK: - Extensions
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
        
        cell.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.textLabel?.textColor = .ypBlackIOS
        cell.selectionStyle = .none
        
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlueIOS
        daySwitch.tag = indexPath.row
        daySwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        daySwitch.isOn = selectedDays.contains(indexPath.row)
        
        cell.accessoryView = daySwitch
        cell.textLabel?.text = weekDays[indexPath.row]
        
        if indexPath.row == weekDays.count - 1 {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                } else {
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                }
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // Убедимся, что сепараторы отображаются правильно
            if indexPath.row == 0 {
                // У первой ячейки тоже должен быть сепаратор снизу
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
}

