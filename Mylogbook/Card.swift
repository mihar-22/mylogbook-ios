
import UIKit

// MARK: Card

@IBDesignable
class Card: UIView {
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        _init()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        _init()
    }
    
    func _init() {
        let cornerRadius: CGFloat = 2
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = Palette.primary.uiColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _init()
    }
}
