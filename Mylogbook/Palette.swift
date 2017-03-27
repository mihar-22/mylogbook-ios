
import UIKit

// MARK: Palette

enum Palette {
    case primary, secondary, secondaryLight
    case seperator, tint, error
    
    var uiColor: UIColor {
        switch self {
        case .primary:
            return UIColor.black
        case .secondary:
            return UIColor.gray
        case .secondaryLight:
            return UIColor.lightGray
        case .seperator:
            return UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 0.8)
        case .tint:
            return UIColor(red: 34/255, green: 181/255, blue: 115/255, alpha: 1)
        case .error:
            return UIColor.red
        }
    }
}

