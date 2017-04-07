
import UIKit

// MARK: Empty Viewing

protocol EmptyView {
    func emptyView(title: String) -> NSAttributedString
    func emptyView(description: String) -> NSAttributedString
    func emptyViewButton(title: String) -> NSAttributedString
}

extension EmptyView {
    func emptyView(title: String) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold),
            NSForegroundColorAttributeName: UIColor.gray
        ]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func emptyView(description: String) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: UIColor.lightGray
        ]
        
        return NSAttributedString(string: description, attributes: attributes)
    }
    
    
    func emptyViewButton(title: String) -> NSAttributedString {
        let attributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: Palette.tint.uiColor
        ]
        
        return NSAttributedString(string: title, attributes: attributes)
    }
}
