import UIKit

final class CategoryViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: CategoryViewModel
    var onCategorySelected: ((String) -> Void)?

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .ypWhiteIOS
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGrayIOS
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 75
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "stub_image"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlackIOS
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypWhiteIOS, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackIOS
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        bindViewModel()
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteIOS

        navigationItem.title = "Категория"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(addButton)

        updateStubVisibility()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),

            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 232),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),

            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateStubVisibility()
        }

        viewModel.onCategorySelected = { [weak self] category in
            self?.onCategorySelected?(category)
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onError = { [weak self] errorMessage in
            self?.showError(errorMessage)
        }
    }

    private func updateStubVisibility() {
        let hasCategories = viewModel.numberOfCategories() > 0
        stubImageView.isHidden = hasCategories
        stubLabel.isHidden = hasCategories
        tableView.isHidden = !hasCategories
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func addButtonTapped() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] categoryTitle in
            self?.viewModel.addCategory(title: categoryTitle)
        }
        navigationController?.pushViewController(newCategoryVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = viewModel.category(at: indexPath.row)
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .ypBlackIOS
        cell.backgroundColor = .ypBackgroundIOS
        cell.selectionStyle = .none

        if viewModel.isSelected(at: indexPath.row) {
            cell.accessoryType = .checkmark
            cell.tintColor = .ypBlueIOS
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }

            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.editCategory(at: indexPath.row)
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.showDeleteConfirmation(at: indexPath.row)
            }

            return UIMenu(title: "", options: .displayInline, children: [editAction, deleteAction])
        }
    }

    private func editCategory(at index: Int) {
        guard let currentTitle = viewModel.category(at: index) else { return }

        let editVC = NewCategoryViewController(initialTitle: currentTitle, isEditing: true)
        editVC.onCategoryCreated = { [weak self] newTitle in
            self?.viewModel.updateCategory(at: index, newTitle: newTitle)
        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func showDeleteConfirmation(at index: Int) {
        let alert = UIAlertController(
            title: nil,
            message: "Это категория точно не нужна?",
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: index)
        }

        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
