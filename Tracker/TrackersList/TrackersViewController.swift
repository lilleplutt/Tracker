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
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return picker
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
        let dateBarButtonItem = UIBarButtonItem(customView: datePicker)
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
        searchController.searchResultsUpdater = self
        
        // Восстановление заголовка при закрытии поиска
        searchController.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
            var existingCategory = categories[0]
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
        // Конвертируем из системы где воскресенье = 1 в систему где понедельник = 0
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
        let availableWidth = collectionView.frame.width - 32 - 9 // 16 слева + 16 справа
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
}

// MARK: - TrackersCollectionViewCellDelegate
protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell)
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell) {
        // Проверяем, что дата не в будущем
        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return // Нельзя отметить для будущей даты
        }
        
        if let indexPath = collectionView.indexPath(for: cell) {
            let filteredCategories = getFilteredTrackers()
            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
            
            // Нормализуем дату до начала дня для сравнения
            let normalizedDate = calendar.startOfDay(for: currentDate)
            let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
            
            if isCompleted(id: tracker.id, date: currentDate) {
                // Удаляем запись для этой конкретной даты
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
        // Поиск будет реализован позже, если нужно
        collectionView.reloadData()
    }
}

// MARK: - UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // Восстанавливаем заголовок при закрытии поиска
        navigationItem.title = "Трекеры"
    }
}
