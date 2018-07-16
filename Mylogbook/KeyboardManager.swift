
import IQKeyboardManagerSwift

// MARK: Keyboard Manager

class KeyboardManager {
    static func start() {
        IQKeyboardManager.shared.enable = true
        
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        
        IQKeyboardManager.shared.toolbarTintColor = Palette.tint.uiColor
    }
}
