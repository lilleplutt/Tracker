import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 3 : 0
            contentView.layer.borderColor = isSelected ? UIColor.ypBlackIOS.cgColor : nil
            contentView.layer.cornerRadius = 16
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        isSelected = false
    }
    
    private func setUpUI() {
        contentView.addSubview(colorView)
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        colorView.layer.cornerRadius = 10
    }
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
}
