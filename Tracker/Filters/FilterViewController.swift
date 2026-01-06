import UIKit

enum TrackerFilter: Int, CaseIterable {
    case allTrackers = 0
    case todayTrackers = 1
    case completed = 2
    case notCompleted = 3

    var title: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("filter.all_trackers", comment: "All trackers")
        case .todayTrackers:
            return NSLocalizedString("filter.today_trackers", comment: "Trackers for today")
        case .completed:
            return NSLocalizedString("filter.completed", comment: "Completed")
        case .notCompleted:
            return NSLocalizedString("filter.not_completed", comment: "Not completed")
        }
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: FilterViewControllerDelegate?
    var selectedFilter: TrackerFilter = .allTrackers

    //MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .ypWhiteIOS
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    //MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteIOS

        navigationItem.title = NSLocalizedString("filter.title", comment: "Filter screen title")
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - Extensions
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell,
              let filter = TrackerFilter(rawValue: indexPath.row) else {
            return UITableViewCell()
        }

        let isSelected = filter == selectedFilter
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == TrackerFilter.allCases.count - 1

        cell.configure(title: filter.title, isSelected: isSelected, isFirst: isFirst, isLast: isLast)

        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let filter = TrackerFilter(rawValue: indexPath.row) else { return }

        selectedFilter = filter
        tableView.reloadData()

        delegate?.didSelectFilter(filter)
        dismiss(animated: true)
    }
}

