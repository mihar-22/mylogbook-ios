
import UIKit

// MARK: Theme

enum Theme {
    case dark, light
}

// MARK: Dark Theme

enum DarkTheme {
    case base(Alpha), brand, error
    
    enum Alpha: CGFloat {
        case primary = 1.0
        case secondary = 0.54
        case hint = 0.38
        case disabled = 0.34
        case divider = 0.12
    }
    
    var uiColor: UIColor {
        switch self {
        case .base(let alpha):
            return UIColor.black.withAlphaComponent(alpha.rawValue)
        case.brand:
            return UIColor.blue
        case .error:
            return UIColor.red
        }
    }
}

// MARK: Light Theme

enum LightTheme {
    case base(Alpha), brand, error
    
    enum Alpha: CGFloat {
        case primary = 1.0
        case secondary = 0.74
        case hint = 0.50
        case disabled = 0.46
        case divider = 0.12
    }
    
    var uiColor: UIColor {
        switch self {
        case .base(let alpha):
            return UIColor.white.withAlphaComponent(alpha.rawValue)
        case.brand:
            return UIColor.blue
        case .error:
            return UIColor.init(red: 255/255, green: 110/255, blue: 110/255, alpha: 1)
        }
    }
}
