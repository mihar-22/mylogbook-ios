
import UIKit

// MARK: Palette

enum Palette {
    case primary, secondary, secondaryLight
    case placeholder, separator, tint, error
    
    var uiColor: UIColor {
        switch self {
        case .primary:
            return UIColor.black
        case .secondary:
            return UIColor.gray
        case .placeholder:
            return UIColor(red: 193/255, green: 193/255, blue: 194/255, alpha: 1)
        case .secondaryLight:
            return UIColor.lightGray
        case .separator:
            return UIColor(red: 205/255, green: 205/255, blue: 209/255, alpha: 1)
        case .tint:
            return UIColor(red: 34/255, green: 181/255, blue: 115/255, alpha: 1)
        case .error:
            return UIColor.red
        }
    }
}

