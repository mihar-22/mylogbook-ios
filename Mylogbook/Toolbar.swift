
import UIKit

// MARK: Toolbar Style

enum ToolbarStyle {
    case normal
}

// MARK: Toolbar

extension UIToolbar {
    
    // MARK: Buttons
    
    func addDoneButton(target: Any?, action: Selector?) {
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: action)
        
        setItems([spacer, doneButton], animated: false)
    }
    
    // MARK: Styling
    
    func restyle(_ style: ToolbarStyle) {
        switch style {
        case .normal:
            styleNormal()
        }
    }
    
    private func styleNormal() {
        barStyle = .default
        
        tintColor = Palette.tint.uiColor
        
        isTranslucent = true
        
        sizeToFit()
    }
}
