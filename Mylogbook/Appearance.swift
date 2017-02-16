
import UIKit

// MARK: Appearance

class Appearance {
    static func apply() {
        tabBar()
    }
    
    // MARK: Tab Bar
    
    private static func tabBar() {
        UITabBar.appearance().tintColor = DarkTheme.brand.uiColor
    }
}
