
import UIKit

// MARK: Navigation Bar Style

enum NavigationBarStyle {
    case transparent
}

// MARK: Navigation Bar

extension UINavigationBar {
    func restyle(_ style: NavigationBarStyle) {
        switch style {
        case .transparent:
            styleTransparent()
        }
    }
    
    private func styleTransparent() {
        setBackgroundImage(UIImage(), for: .default)
        
        shadowImage = UIImage()
        
        backgroundColor = UIColor.clear
        
        isTranslucent = true
    }
}
