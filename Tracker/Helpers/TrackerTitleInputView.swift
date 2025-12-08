import UIKit

protocol TrackerTitleInputViewDelegate: AnyObject {
    func trackerTitleInputView(_ view: TrackerTitleInputView, didChangeText text: String)
}

final class TrackerTitleInputView: UIView {
    
    // MARK: - Delegate
    weak var delegate: TrackerTitleInputViewDelegate?
    
    // MARK: - Views
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlackIOS
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .go
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
    
    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRedIOS
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backgroundContainerView, errorMessageLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Private Properties
    private let maxCharacterCount = 38
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDependencies()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Dependencies
    private func configureDependencies() {
        titleTextField.delegate = self
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        addSubview(contentStackView)
        backgroundContainerView.addSubview(titleTextField)
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            backgroundContainerView.heightAnchor.constraint(equalToConstant: 75),
            backgroundContainerView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            
            errorMessageLabel.heightAnchor.constraint(equalToConstant: 38),
            
            titleTextField.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -12),
            titleTextField.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        titleTextField.addTarget(self, action: #selector(titleTextFieldEditingChanged), for: .editingChanged)
    }
    
    private func isTextTooLong(_ text: String) -> Bool {
        return text.count > maxCharacterCount
    }
    
    // MARK: - Actions
    @objc private func titleTextFieldEditingChanged() {
        let text = titleTextField.text ?? ""
        errorMessageLabel.isHidden = !isTextTooLong(text)
        delegate?.trackerTitleInputView(self, didChangeText: text)
    }
}

// MARK: - UITextFieldDelegate
extension TrackerTitleInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isTooLong = isTextTooLong(updatedText)
        if isTooLong {
            errorMessageLabel.isHidden = !isTooLong
        }
        return !isTooLong
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

