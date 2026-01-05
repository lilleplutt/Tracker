import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Properties
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private var searchText: String = ""

    // MARK: - Initializers
    init() {
        self.trackerStore = TrackerStore()
        self.categoryStore = TrackerCategoryStore()
        self.recordStore = TrackerRecordStore()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        label.text = NSLocalizedString("trackers_list.stub_message", comment: "Trackers list stub message")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchStubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .searchStub))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let searchStubLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers_list.search_stub_message", comment: "Search stub message")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlackIOS)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString("trackers_list.search_bar", comment: "Search bar placeholder")
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
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
        label.textColor = UIColor(resource: .ypUniversalBlackIOS)
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("trackers_list.filter_button", comment: "Filter button title"), for: .normal)
        button.setTitleColor(.ypUniversalWhiteIOS, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .ypBlueIOS
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date() {
        didSet {
            updateVisibleCategories()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupStores()
        loadDataFromCoreData()
        updateStubVisibility()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.reportScreenOpen(.main)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.reportScreenClose(.main)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)

        view.addSubview(collectionView)
        view.addSubview(stubImage)
        view.addSubview(stubTitleLabel)
        view.addSubview(searchStubImage)
        view.addSubview(searchStubLabel)
        view.addSubview(filterButton)

        setupNavigationBar()
        setupCollectionView()
        searchController.searchResultsUpdater = self

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = true
        }
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

        navigationItem.title = NSLocalizedString("trackers_list.title", comment: "Trackers screen title")
        navigationItem.largeTitleDisplayMode = .always

        if #available(iOS 26.0, *) {
            navigationItem.largeTitle = NSLocalizedString("trackers_list.title", comment: "Trackers screen large title")
        }

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 82, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 82, right: 0)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // https://stackoverflow.com/questions/79778204/navigation-item-title-hidden-when-using-large-title-in-ios26
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),

            stubTitleLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            searchStubImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            searchStubImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            searchStubImage.widthAnchor.constraint(equalToConstant: 80),
            searchStubImage.heightAnchor.constraint(equalToConstant: 80),

            searchStubLabel.topAnchor.constraint(equalTo: searchStubImage.bottomAnchor, constant: 8),
            searchStubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func plusButtonTapped() {
        AnalyticsService.shared.reportClick(screen: .main, item: .addTrack)

        let newHabitVC = NewHabitViewController()
        let navController = UINavigationController(rootViewController: newHabitVC)
        newHabitVC.onCreateTracker = { [weak self] tracker, categoryTitle in
            self?.addNewTracker(tracker, categoryTitle: categoryTitle)
        }
        present(navController, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        AnalyticsService.shared.reportClick(screen: .main, item: .filter)

        let filterVC = FilterViewController()
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        dateLabel.text = dateFormatter.string(from: datePicker.date)
        updateStubVisibility()
    }
    
    private func setupStores() {
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }

    private func loadDataFromCoreData() {
        let coreDataCategories = categoryStore.categories
        categories = coreDataCategories.compactMap { $0.toTrackerCategory() }

        let coreDataRecords = recordStore.records
        completedTrackers = Set(coreDataRecords.compactMap { $0.toTrackerRecord() })

        updateVisibleCategories()
        collectionView.reloadData()
    }

    private func addNewTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            var category = categoryStore.fetchCategory(by: categoryTitle)
            if category == nil {
                category = try categoryStore.addCategory(title: categoryTitle)
            }

            guard let category = category,
                  let colorHex = tracker.color.toHex() else {
                return
            }

            let scheduleString = tracker.schedule.toString()
            try trackerStore.addTracker(
                id: tracker.id,
                title: tracker.title,
                emoji: tracker.emoji,
                colorHex: colorHex,
                schedule: scheduleString,
                category: category
            )

            loadDataFromCoreData()
            updateStubVisibility()
        } catch {
            print("Error saving tracker: \(error)")
        }
    }

    private func editTracker(_ tracker: Tracker) {
        let completedDaysCount = getCurrentQuantity(id: tracker.id)

        var categoryTitle = ""
        for category in categories {
            if category.trackers.contains(where: { $0.id == tracker.id }) {
                categoryTitle = category.title
                break
            }
        }

        let newHabitVC = NewHabitViewController()
        newHabitVC.configureForEditing(tracker: tracker, categoryTitle: categoryTitle, completedDaysCount: completedDaysCount)

        newHabitVC.onCreateTracker = { [weak self] updatedTracker, categoryTitle in
            self?.updateTracker(updatedTracker, categoryTitle: categoryTitle)
        }

        let navController = UINavigationController(rootViewController: newHabitVC)
        present(navController, animated: true)
    }

    private func updateTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            guard let trackerCoreData = trackerStore.fetchTracker(by: tracker.id),
                  let colorHex = tracker.color.toHex() else {
                return
            }

            var category = categoryStore.fetchCategory(by: categoryTitle)
            if category == nil {
                category = try categoryStore.addCategory(title: categoryTitle)
            }

            guard let category = category else {
                return
            }

            trackerCoreData.title = tracker.title
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.colorHex = colorHex
            trackerCoreData.scheduleData = tracker.schedule.toString()
            trackerCoreData.category = category

            try trackerStore.updateTracker(trackerCoreData)

            loadDataFromCoreData()
        } catch {
            print("Error updating tracker: \(error)")
        }
    }

    private func confirmDeleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("delete_confirmation.title", comment: "Delete confirmation"),
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_confirmation.delete", comment: "Delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("delete_confirmation.cancel", comment: "Cancel"),
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        do {
            guard let trackerCoreData = trackerStore.fetchTracker(by: tracker.id) else {
                return
            }

            try trackerStore.deleteTracker(trackerCoreData)

            completedTrackers = completedTrackers.filter { $0.trackerId != tracker.id }

            loadDataFromCoreData()
            updateStubVisibility()
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.date = currentDate
        dateLabel.text = dateFormatter.string(from: currentDate)
        navigationItem.title = NSLocalizedString("trackers_list.title", comment: "Trackers screen title")
    }
    
    private func updateStubVisibility() {
        let hasTrackers = !visibleCategories.isEmpty && !visibleCategories.allSatisfy { $0.trackers.isEmpty }
        let isSearching = !searchText.isEmpty
        let hasNoResults = isSearching && !hasTrackers

        stubImage.isHidden = hasTrackers || isSearching
        stubTitleLabel.isHidden = hasTrackers || isSearching
        searchStubImage.isHidden = !hasNoResults
        searchStubLabel.isHidden = !hasNoResults
    }
    
    private func isCompleted(id: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        return completedTrackers.contains { record in
            record.trackerId == id && calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }
    }
    
    private func getCurrentQuantity(id: UUID) -> Int {
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
    
    private func updateVisibleCategories() {
        var filteredByDate = categories.map { category in
            let filteredTrackers = category.trackers.filter { trackerMatchesDate($0, date: currentDate) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }

        if !searchText.isEmpty {
            filteredByDate = filteredByDate.map { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(searchText.lowercased())
                }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }

        visibleCategories = filteredByDate
    }

    private func getFilteredTrackers() -> [TrackerCategory] {
        return visibleCategories
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
        let quantity = getCurrentQuantity(id: tracker.id)
        
        cell.configure(with: tracker, isCompleted: isCompleted, quantity: quantity)
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
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 8, right: 16)
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

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let filteredCategories = getFilteredTrackers()
        guard indexPath.section < filteredCategories.count,
              indexPath.row < filteredCategories[indexPath.section].trackers.count else {
            return nil
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil, actionProvider: { _ in
            let editAction = UIAction(
                title: NSLocalizedString("context_menu.edit", comment: "Edit")
            ) { [weak self] _ in
                AnalyticsService.shared.reportClick(screen: .main, item: .edit)
                self?.editTracker(tracker)
            }

            let deleteAction = UIAction(
                title: NSLocalizedString("context_menu.delete", comment: "Delete"),
                attributes: .destructive
            ) { [weak self] _ in
                AnalyticsService.shared.reportClick(screen: .main, item: .delete)
                self?.confirmDeleteTracker(tracker)
            }

            return UIMenu(children: [editAction, deleteAction])
        })
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else {
            return nil
        }

        return UITargetedPreview(view: cell.getColorView())
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell else {
            return nil
        }

        return UITargetedPreview(view: cell.getColorView())
    }
}

// MARK: - TrackersCollectionViewCellDelegate
protocol TrackersCollectionViewCellDelegate: AnyObject {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell)
}

extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func completeButtonDidTap(in cell: TrackersCollectionViewCell) {
        AnalyticsService.shared.reportClick(screen: .main, item: .track)

        let calendar = Calendar.current
        if calendar.compare(currentDate, to: Date(), toGranularity: .day) == .orderedDescending {
            return
        }

        if let indexPath = collectionView.indexPath(for: cell) {
            let filteredCategories = getFilteredTrackers()
            let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]

            let normalizedDate = calendar.startOfDay(for: currentDate)

            do {
                if isCompleted(id: tracker.id, date: currentDate) {
                    try recordStore.deleteRecord(trackerId: tracker.id, date: normalizedDate)

                    if let recordToRemove = completedTrackers.first(where: { existingRecord in
                        existingRecord.trackerId == tracker.id && calendar.isDate(existingRecord.date, inSameDayAs: normalizedDate)
                    }) {
                        completedTrackers.remove(recordToRemove)
                    }
                } else {
                    try recordStore.addRecord(trackerId: tracker.id, date: normalizedDate)
                    let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
                    completedTrackers.insert(record)
                }

                collectionView.reloadItems(at: [indexPath])
            } catch {
                print("Error updating tracker record: \(error)")
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        updateVisibleCategories()
        updateStubVisibility()
        collectionView.reloadData()
    }
}

// MARK: - Store Delegates
extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate() {
        loadDataFromCoreData()
        updateStubVisibility()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate() {
        loadDataFromCoreData()
        updateStubVisibility()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdate() {
        loadDataFromCoreData()
    }
}
