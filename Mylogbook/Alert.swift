
import PopupDialog

// MARK: Alertable

protocol Alertable {
    func showAlert(title: String, message: String, buttons: [PopupDialogButton], buttonAlignment: UILayoutConstraintAxis)
}

extension Alertable where Self: UIViewController {
    func showAlert(title: String, message: String, buttons: [PopupDialogButton], buttonAlignment: UILayoutConstraintAxis = .horizontal) {
        let popup = PopupDialog(title: title, message: message)
        
        popup.buttonAlignment = buttonAlignment
        
        popup.addButtons(buttons)
        
        present(popup, animated: true, completion: nil)
    }
}
