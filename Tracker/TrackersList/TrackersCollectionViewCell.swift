import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        backgroundColor = .ypBlueIOS
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    func configure(with tracker: Tracker) {
        backgroundColor = tracker.color
    }
}

