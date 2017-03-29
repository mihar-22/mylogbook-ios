
import UIKit

// MARK: Tab Bar

extension UITabBarController {
    func renderOriginalImages() {
        guard let items = tabBar.items, items.count > 0 else { return }
        
        for item in items {
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
    }
}
