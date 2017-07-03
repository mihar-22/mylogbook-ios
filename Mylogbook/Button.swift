
import UIKit

// MARK: Button Style

enum ButtonStyle {
    case normal
    case disabled
    case shadow
}

// MARK: Button

extension UIButton {
    
    // MARK: Styling
    
    func restyle(_ style: ButtonStyle) {
        switch style {
        case .normal:
            styleNormal()
        case .disabled:
            styleDisabled()
        case .shadow:
            styleWithShadow()
        }
    }
    
    private func styleNormal() {
        tintColor = Palette.tint.uiColor
    }
    
    private func styleWithShadow() {
        layer.masksToBounds = false
        layer.shadowColor = Palette.secondary.uiColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.1)
        layer.shadowOpacity = 0.3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 2).cgPath
    }
    
    func styleDisabled() {
        tintColor = UIColor.lightGray
    }
}
