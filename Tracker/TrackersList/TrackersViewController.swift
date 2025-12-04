import UIKit

final class TrackersViewController: UIViewController {
    //MARK: - UI elements
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
    
    private let dateButton: UIButton = {
        let button = UIButton()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let currentDate = formatter.string(from: Date())
        
        button.setTitle(currentDate, for: .normal)
        button.setTitleColor(.ypBlackIOS, for: .normal)
        button.backgroundColor = UIColor(resource: .ypBackgroundIOS)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "trackerCell")
        
        setUpNavigationBar()
        setUpView()
        setUpConstraints()
    }
    
    //MARK: - Public properties
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    //MARK: - Private properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    //MARK: - Private methods
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 236),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 428),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setUpNavigationBar() {
        let dateBarButtonItem = UIBarButtonItem(customView: dateButton)
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
        
        NSLayoutConstraint.activate([
            dateButton.widthAnchor.constraint(equalToConstant: 77),
            dateButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(resource: .ypWhiteIOS)
        view.addSubview(stubImage)
        view.addSubview(stubTitleLabel)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            stubImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 147),
            stubImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            
            stubTitleLabel.topAnchor.constraint(equalTo: stubImage.bottomAnchor, constant: 8),
            stubTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stubTitleLabel.widthAnchor.constraint(equalToConstant: 343)
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
    
    private func addNewTracker(_ tracker: Tracker) {
        let category = TrackerCategory(
            title: "Важное",
            trackers: [tracker]
        )
        
        categories.append(category)
        collectionView.reloadData()
        updateStubVisibility()
    }
    
    private func updateStubVisibility() {
        let hasTrackers = !categories.isEmpty
        stubImage.isHidden = hasTrackers
        stubTitleLabel.isHidden = hasTrackers
    }
}

// MARK: - Extensions
extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < categories.count else { return 0 }
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "trackerCell",
                    for: indexPath
                ) as? TrackersCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                // Получаем трекер
                let tracker = categories[indexPath.section].trackers[indexPath.row]
                
                // Считаем выполненные дни для этого трекера
                let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
                
                // Настраиваем ячейку
                cell.configure(with: tracker, completedDays: completedDays)
                
                return cell
            }
    
    
    
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
}

