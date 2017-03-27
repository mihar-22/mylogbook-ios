
import PopupDialog
import UIKit

// MARK: Appearance

class Appearance {
    static func apply() {
        popupDialog()
        
        tabBar()
    }
    
    // MARK: Popup Dialog
    
    private static func popupDialog() {
        let appearance = PopupDialogDefaultView.appearance()
        
        appearance.titleFont = UIFont.boldSystemFont(ofSize: 17)
        appearance.messageFont = UIFont.systemFont(ofSize: 14)
        
        let defaultButtonAppearance = DefaultButton.appearance()
        
        defaultButtonAppearance.titleColor = Palette.tint.uiColor
    }
    
    // MARK: Tab Bar
    
    private static func tabBar() {
        UITabBar.appearance().tintColor = Palette.tint.uiColor
    }
}
