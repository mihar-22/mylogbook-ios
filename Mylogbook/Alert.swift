
import PopupDialog

// MARK: Alerting

protocol Alerting {
    func showAlert(title: String,
                   message: String,
                   buttons: [PopupDialogButton],
                   buttonAlignment: UILayoutConstraintAxis)
    
    func showCustomAlert(viewController: UIViewController,
                         buttons: [PopupDialogButton],
                         buttonAlignment: UILayoutConstraintAxis)
}

extension Alerting where Self: UIViewController {
    func showAlert(title: String,
                   message: String,
                   buttons: [PopupDialogButton],
                   buttonAlignment: UILayoutConstraintAxis = .horizontal) {
        
        let popup = PopupDialog(title: title, message: message)
        
        popup.buttonAlignment = buttonAlignment
        
        popup.addButtons(buttons)
        
        present(popup, animated: true, completion: nil)
    }
    
    func showCustomAlert(viewController: UIViewController,
                         buttons: [PopupDialogButton],
                         buttonAlignment: UILayoutConstraintAxis = .horizontal) {
        
        let popup = PopupDialog(viewController: viewController)
        
        popup.buttonAlignment = buttonAlignment
        
        popup.addButtons(buttons)
        
        present(popup, animated: true, completion: nil)
    }
}

// MARK: Default Button

enum DefaultButtonStyle {
    case normal, disabled
}

extension DefaultButton {
    func restyle(_ style: DefaultButtonStyle) {
        switch style {
        case .normal:
            styleNormal()
        case .disabled:
            styleDisabled()
        }
    }
    
    private func styleNormal() {
        titleColor = UIColor(red: 0.25, green: 0.53, blue: 0.91, alpha: 1)
    }
    
    private func styleDisabled() {
        titleColor = UIColor.lightGray
    }
}
