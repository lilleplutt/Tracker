import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var plusButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .plusButton),
            target: self,
            action: #selector(plusButtonTapped)
        )
        button.tintColor = UIColor(resource: .ypBlackIOS)
        return button
    }()
    
    private let stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .stub))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stubTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.backgroundColor = UIColor(resource: .ypDateIOS)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.text = dateFormatter.string(from: datePicker.date)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private lazy var dateContainerView: UIView = {
        let view = UIView()
        view.addSubview(datePicker)
        view.insertSubview(dateLabel, aboveSubview: datePicker)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        updateStubVisibility()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)
        
        view.addSubview(collectionView)
        view.addSubview(stubImage)
        view.addSubview(stubTitleLabel)
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        setupDatePickerConstraints()
        
        let dateBarButtonItem = UIBarButtonItem(customView: dateContainerView)
        let plusBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusBarButtonItem
        navigationItem.rightBarButtonItem = dateBarButtonItem
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationItem.title = "Трекеры"
        navigationItem.searchController = searchController
    }
    
    private func setupDatePickerConstraints() {
        NSLayoutConstraint.activate([
            dateContainerView.widthAnchor.constraint(equalToConstant: 77),
            dateContainerView.heightAnchor.constraint(equalToConstant: 34),
            
            datePicker.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: dateContainerView.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            
            stubTitleLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func plusButtonTapped() {
        let newHabitVC = NewHabitViewController()
        let navController = UINavigationController(rootViewController: newHabitVC)
        newHabitVC.onCreateTracker = { [weak self] tracker in
            self?.addNewTracker(tracker)
        }
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        updateStubVisibility()
    }
    
    private func addNewTracker(_ tracker: Tracker) {
        if categories.isEmpty {
            let category = TrackerCategory(
                title: "Важное",
                trackers: [tracker]
            )
            categories.append(category)
        } else {
            let existingCategory = categories[0]
            var updatedTrackers = existingCategory.trackers
            updatedTrackers.append(tracker)
            categories[0] = TrackerCategory(
                title: existingCategory.title,
                trackers: updatedTrackers
            )
        }
        
        collectionView.reloadData()
        updateStubVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.date = currentDate
        dateLabel.text = dateFormatter.string(from: currentDate)
        navigationItem.title = "Трекеры"
    }
    
    private func updateStubVisibility() {
        let filteredCategories = getFilteredTrackers()
        let hasTrackers = !filteredCategories.isEmpty && !filteredCategories.allSatisfy { $0.trackers.isEmpty }
        stubImage.isHidden = hasTrackers
        stubTitleLabel.isHidden = hasTrackers
    }
    
    private func getDayString(_ value: Int) -> String {
        let mod10 = value % 10
        let mod100 = value % 100
        
        let word: String = {
            switch (mod100, mod10) {
            case (11...14, _):
                return "дней"
            case (_, 1):
                return "день"
            case (_, 2...4):
                return "дня"
            default:
                return "дней"
            }
        }()
        
        return "\(value) \(word)"
    }
    
    private func isCompleted(id: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        return completedTrackers.contains { record in
            record.trackerId == id && calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }
    }
    
    private func getCurrentQuanity(id: UUID) -> Int {
        return completedTrackers.filter { $0.trackerId == id }.count
    }
    
    private func getWeekday(from date: Date) -> Int {
        let calendar = Calendar.current
        var weekday = calendar.component(.weekday, from: date)
        weekday = (weekday + 5) % 7
        return weekday
    }
    
    private func trackerMatchesDate(_ tracker: Tracker, date: Date) -> Bool {
        let weekday = getWeekday(from: date)
        return tracker.schedule.contains { $0.weekday == weekday }
    }
    
    private func getFilteredTrackers() -> [TrackerCategory] {
        return categories.map { category in
            let filteredTrackers = category.trackers.filter { trackerMatchesDate($0, date: currentDate) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getFilteredTrackers().count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filteredCategories = getFilteredTrackers()
        guard section < filteredCategories.count else { return 0 }
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "trackerCell",
            for: indexPath
        ) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let filteredCategories = getFilteredTrackers()
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let isCompleted = isCompleted(id: tracker.id, date: currentDate)
        let quanity = getCurrentQuanity(id: tracker.id)
        
        cell.configure(with: tracker, isCompleted: isCompleted, quanity: quanity)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 38)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "header",
            for: indexPath
        )
        
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        let filteredCategories = getFilteredTrackers()
        guard indexPath.section < filteredCategories.count else {
            return headerView
        }
        
        let category = filteredCategories[indexPath.section]
        let label = UILabel()
        label.text = category.title
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 28),
            label.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        return headerView
    }
}

// MARK: - TrackersCollectionViewCellDelegate
protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell)
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell) {
        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return
        }
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let filteredCategories = getFilteredTrackers()
            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
            
            let normalizedDate = calendar.startOfDay(for: currentDate)
            let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
            
            if isCompleted(id: tracker.id, date: currentDate) {
                if let recordToRemove = completedTrackers.first(where: { existingRecord in
                    existingRecord.trackerId == tracker.id && calendar.isDate(existingRecord.date, inSameDayAs: normalizedDate)
                }) {
                    completedTrackers.remove(recordToRemove)
                }
            } else {
                completedTrackers.insert(record)
            }
            
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView.reloadData()
    }
}

