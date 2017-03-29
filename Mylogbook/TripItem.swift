
import UIKit

// MARK: Trip Item Style

enum TripItemStyle {
    case normal, selected
}

// MARK: Trip Item

@IBDesignable
class TripItem: UIView, NibView {
    
    var isSelected = false
    
    // MARK: Inspectables
    
    @IBInspectable var image: UIImage {
        get {
            return icon.image ?? UIImage()
        }
        
        set(image) {
            icon.image = image
        }
    }
    
    @IBInspectable var title: String {
        get {
            return titleLabel.text ?? "Title"
        }
        
        set(title) {
            titleLabel.text = title
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Initializers
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initNib()
        
        restyle(.normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initNib()
        
        restyle(.normal)
    }
    
    // MARK: Actions
    
    @IBAction func didSelectItem(_ sender: UITapGestureRecognizer) {
        isSelected = !isSelected
        
        let state: TripItemStyle = isSelected ? .selected : .normal
        
        restyle(state)
    }
    
    // Styling
    
    func restyle(_ style: TripItemStyle) {
        switch style {
        case .normal:
            styleNormal()
        case .selected:
            styleSelected()
        }
    }
    
    private func styleNormal() {
        let alpha: CGFloat = 0.3
        
        icon.alpha = alpha
        titleLabel.alpha = alpha
        checkmarkImage.isHidden = true
    }
    
    private func styleSelected() {
        let alpha: CGFloat = 1
        
        icon.alpha = alpha
        titleLabel.alpha = alpha
        checkmarkImage.isHidden = false
    }
}
