import UIKit

protocol TrackerTitleInputCellDelegate: AnyObject {
    func trackerTitleInputCell(_ cell: TrackerTitleInputCell, didChangeText text: String)
    func trackerTitleInputCellDidRequestLayoutUpdate(_ cell: TrackerTitleInputCell)
}

final class TrackerTitleInputCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "TrackerTitleInputCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: TrackerTitleInputCellDelegate?
    
    // MARK: - Views
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.textColor = .ypBlackIOS
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .go
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    private lazy var backgroundContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackgroundIOS
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRedIOS
        label.text = "Ограничение 38 символов"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backgroundContainerView, errorMessageLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    // MARK: - Private Properties
    
    private let maxCharacterCount = 38
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(contentStackView)
        backgroundContainerView.addSubview(titleTextField)
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            backgroundContainerView.heightAnchor.constraint(equalToConstant: 75),
            backgroundContainerView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            
            errorMessageLabel.heightAnchor.constraint(equalToConstant: 38),
            
            titleTextField.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -12),
            titleTextField.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        titleTextField.addTarget(self, action: #selector(titleTextFieldEditingChanged), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc private func titleTextFieldEditingChanged() {
        let text = titleTextField.text ?? ""
        errorMessageLabel.isHidden = !isTextTooLong(text)
        requestLayoutUpdate()
        delegate?.trackerTitleInputCell(self, didChangeText: text)
    }
    
    // MARK: - Private Methods
    
    private func requestLayoutUpdate() {
        delegate?.trackerTitleInputCellDidRequestLayoutUpdate(self)
    }
    
    private func isTextTooLong(_ text: String) -> Bool {
        return text.count > maxCharacterCount
    }
}

// MARK: - UITextFieldDelegate

extension TrackerTitleInputCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        let isTooLong = isTextTooLong(updatedText)
        if isTooLong {
            errorMessageLabel.isHidden = !isTooLong
            requestLayoutUpdate()
        }
        return !isTooLong
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

