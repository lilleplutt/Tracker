import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Private Properties
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Public Methods
    func configure(color: UIColor) {
        
    }
}
