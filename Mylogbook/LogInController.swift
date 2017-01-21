
import UIKit
import PopupDialog

class LogInController: UIViewController {
    let validator = Validator()
  
    var email: String? { return emailTextField.text }
    var password: String? { return passwordTextField.text }

    // MARK: Outlets
    
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        setupValidator()
        
        attemptToPrefillForm()
        
        setupTextFields()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.delegate = self
        
        validator.setActionButton(doneButton)

        validator.addField(emailTextField, emailErrorLabel, [.required, .email])
        
        validator.addField(passwordTextField, passwordErrorLabel, [.required, .minLength(min: 6)])
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        emailTextField.tag = 0
        emailTextField.delegate = self
        
        passwordTextField.tag = 1
        passwordTextField.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func didTapDone(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        logInUser()
    }
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapForgotPassword(_ sender: UIButton) {
        view.endEditing(true)
        
        forgotPassword()
    }
    
    // MARK: Networking
    
    func logInUser() {        
        let route = AuthRoute.login(email: email!, password: password!)
        
        Session.shared.requestJSON(route) { response in
            guard response.statusCode != 400 else {
                self.showInvalidCredentialsAlert()
                
                return
            }
            
            self.storeUserDetails(response.data!)
            
            self.navigateToDashboardScene()
        }
    }
    
    func forgotPassword() {
        let route = AuthRoute.forgot(email: email!)
        
        Session.shared.requestJSON(route) { response in
            guard response.statusCode != 422 else {
                if response.errors!["email"] != nil { self.showInvalidEmailAlert() }
                
                return
            }
            
            self.showForgotPasswordLinkSentAlert()
        }
    }
    
    // MARK: Keychain
    
    func attemptToPrefillForm() {
        emailTextField.text = Keychain.shared.email ?? ""
        
        passwordTextField.text = Keychain.shared.password ?? ""
        
        validator.revalidate(updateUI: false)
    }
    
    func storeUserDetails(_ data: [String: Any]) {
        Keychain.shared.name = (data["name"] as! String)
        Keychain.shared.email = email!
        Keychain.shared.password = nil
        Keychain.shared.apiToken = (data["api_token"] as! String)
    }
    
    // MARK: Navigation
    
    func navigateToDashboardScene() {
        performSegue(withIdentifier: "userLoggedInSegue", sender: nil)
    }
    
    func navigateToMailBox() {
        let mailUrl = URL(string: "message://")!
        
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK: Alertable

extension LogInController: Alertable {
    func showInvalidCredentialsAlert() {
        let title = "Log In Failed"
        
        let message = "Log in failed due to a bad email and password combination or you have not verified your email."
        
        let cancelButton = CancelButton(title: "TRY AGAIN", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
    }
    
    func showInvalidEmailAlert() {
        let title = "Bad Email"
        
        let message = "A reset link could not be sent because no account exists with this email."
        
        let cancelButton = CancelButton(title: "TRY AGAIN", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
    }
    
    func showForgotPasswordLinkSentAlert() {
        let title = "Reset Link Sent"
        
        let message = "An email has been sent to you. Please go to your inbox and click on the link. The link will provide you with a form to reset your password."
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        let openMailButton = DefaultButton(title: "OPEN MAIL") { self.navigateToMailBox() }
        
        showAlert(title: title, message: message, buttons: [cancelButton, openMailButton])
    }
}

// MARK: Text Field Delegate

extension LogInController: TextFieldDelegate {    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: Validator Delegate

extension LogInController: ValidatorDelegate {
    func validationSuccessful(_ textField: TextField) {
        if textField.tag == emailTextField.tag { forgotPasswordButton.isEnabled = true }
    }
    
    func validationFailed(_ textField: TextField) {
        if textField.tag == emailTextField.tag { forgotPasswordButton.isEnabled = false }
    }
}
