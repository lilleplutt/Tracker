import UIKit

final class NewCategoryViewController: UIViewController {

    // MARK: - Properties
    var onCategoryCreated: ((String) -> Void)?
    private var categoryTitle: String = ""
    private let isEditingMode: Bool

    // MARK: - UI Elements
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("newCategory.text_field", comment: "New category text field placeholder")
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlackIOS
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundIOS
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("newCategory.done_button", comment: "Done button title"), for: .normal)
        button.setTitleColor(.ypWhiteIOS, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGrayIOS
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    // MARK: - Initializer
    init(initialTitle: String? = nil, isEditing: Bool = false) {
        self.isEditingMode = isEditing
        super.init(nibName: nil, bundle: nil)
        if let initialTitle = initialTitle {
            self.categoryTitle = initialTitle
        }
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
        updateDoneButtonState()

        if !categoryTitle.isEmpty {
            titleTextField.text = categoryTitle
            updateDoneButtonState()
        }
    }

    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypWhiteIOS

        navigationItem.title = NSLocalizedString("newCategory.title", comment: "New category screen title")
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.ypBlackIOS,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationItem.hidesBackButton = true

        titleTextField.delegate = self

        view.addSubview(backgroundContainerView)
        backgroundContainerView.addSubview(titleTextField)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backgroundContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backgroundContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backgroundContainerView.heightAnchor.constraint(equalToConstant: 75),

            titleTextField.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -12),
            titleTextField.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),

            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        titleTextField.addTarget(self, action: #selector(titleTextFieldEditingChanged), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    private func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        let isTextValid = !text.trimmingCharacters(in: .whitespaces).isEmpty
        doneButton.isEnabled = isTextValid
        doneButton.backgroundColor = isTextValid ? .ypBlackIOS : .ypGrayIOS
    }

    @objc private func titleTextFieldEditingChanged() {
        updateDoneButtonState()
    }

    @objc private func doneButtonTapped() {
        guard let text = titleTextField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty else { return }

        onCategoryCreated?(text)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if doneButton.isEnabled {
            doneButtonTapped()
        }
        return true
    }
}
