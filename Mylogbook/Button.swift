
import UIKit

// MARK: Button Style

enum ButtonStyle {
    case normal
    case disabled
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
        }
    }
    
    private func styleNormal() {
        tintColor = DarkTheme.brand.uiColor
    }
    
    func styleDisabled() {
        tintColor = UIColor.lightGray
    }
}
