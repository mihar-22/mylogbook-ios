
import IQKeyboardManagerSwift

// MARK: Keyboard Manager

class KeyboardManager {
    static func start() {
        IQKeyboardManager.sharedManager().enable = true
        
        IQKeyboardManager.sharedManager().shouldShowTextFieldPlaceholder = false
        
        IQKeyboardManager.sharedManager().toolbarTintColor = DarkTheme.brand.uiColor
    }
}
