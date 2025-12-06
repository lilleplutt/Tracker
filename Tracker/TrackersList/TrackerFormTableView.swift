import UIKit

protocol TrackerFormTableViewDelegate: AnyObject {
    func trackerFormTableView(_ tableView: TrackerFormTableView, didChangeTitle text: String)
    func trackerFormTableView(_ tableView: TrackerFormTableView, didSelectCategoryAt indexPath: IndexPath)
    func trackerFormTableView(_ tableView: TrackerFormTableView, didSelectScheduleAt indexPath: IndexPath)
    func trackerFormTableViewDidRequestLayoutUpdate(_ tableView: TrackerFormTableView)
}

final class TrackerFormTableView: UIView {
    
    // MARK: - Delegate
    
    weak var delegate: TrackerFormTableViewDelegate?
    
    // MARK: - Private Properties
    
    private enum SectionType: Int, CaseIterable {
        case titleInput, options
    }
    
    private enum OptionType: Int, CaseIterable {
        case category, schedule
    }
    
    private var trackerState: NewTrackerState {
        didSet {
            updateDisplayedData()
        }
    }
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TrackerTitleInputCell.self, forCellReuseIdentifier: TrackerTitleInputCell.reuseID)
        tableView.register(TrackerOptionCell.self, forCellReuseIdentifier: TrackerOptionCell.reuseID)
        tableView.backgroundColor = .ypWhiteIOS
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Initializer
    
    init(initialState: NewTrackerState) {
        self.trackerState = initialState
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateState(_ newState: NewTrackerState) {
        trackerState = newState
    }
    
    func reloadScheduleRow() {
        let scheduleIndexPath = IndexPath(row: OptionType.schedule.rawValue, section: SectionType.options.rawValue)
        tableView.reloadRows(at: [scheduleIndexPath], with: .none)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateDisplayedData() {
        tableView.reloadData()
    }
    
    private func makeTitleInputCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerTitleInputCell.reuseID,
            for: indexPath
        ) as? TrackerTitleInputCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
    
    private func makeOptionCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let optionType = OptionType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackerOptionCell.reuseID,
            for: indexPath
        ) as? TrackerOptionCell else {
            return UITableViewCell()
        }
        
        let configuration = makeOptionConfiguration(for: optionType)
        cell.configure(with: configuration)
        return cell
    }
    
    private func makeOptionConfiguration(for optionType: OptionType) -> TrackerOptionConfiguration {
        switch optionType {
        case .category:
            return TrackerOptionConfiguration(
                title: "Категория",
                subtitle: trackerState.category,
                isFirst: true,
                isLast: false
            )
        case .schedule:
            let scheduleString = Weekday.formattedWeekdays(Array(trackerState.schedule))
            return TrackerOptionConfiguration(
                title: "Расписание",
                subtitle: scheduleString,
                isFirst: false,
                isLast: true
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerFormTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        SectionType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SectionType(rawValue: section) else {
            return 0
        }
        switch sectionType {
        case .titleInput:
            return 1
        case .options:
            return OptionType.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = SectionType(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .titleInput:
            return makeTitleInputCell(tableView, for: indexPath)
        case .options:
            return makeOptionCell(tableView, for: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate

extension TrackerFormTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = SectionType(rawValue: indexPath.section),
              sectionType == .options else {
            return
        }
        
        guard let optionType = OptionType(rawValue: indexPath.row) else {
            return
        }
        
        switch optionType {
        case .category:
            delegate?.trackerFormTableView(self, didSelectCategoryAt: indexPath)
        case .schedule:
            delegate?.trackerFormTableView(self, didSelectScheduleAt: indexPath)
        }
    }
}

// MARK: - TrackerTitleInputCellDelegate

extension TrackerFormTableView: TrackerTitleInputCellDelegate {
    func trackerTitleInputCell(_ cell: TrackerTitleInputCell, didChangeText text: String) {
        delegate?.trackerFormTableView(self, didChangeTitle: text)
    }
    
    func trackerTitleInputCellDidRequestLayoutUpdate(_ cell: TrackerTitleInputCell) {
        tableView.beginUpdates()
        tableView.endUpdates()
        delegate?.trackerFormTableViewDidRequestLayoutUpdate(self)
    }
}
