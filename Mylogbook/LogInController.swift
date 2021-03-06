
import Alamofire
import Dispatch
import PopupDialog
import SwiftyJSON
import UIKit

class LogInController: UIViewController, ActivityView {
    let validator = Validator()
  
    let network = NetworkReachabilityManager(host: Env.MLB_API_BASE)!
    
    var email: String? { return emailTextField.text }
    var password: String? { return passwordTextField.text }
    
    var signUpPassword: String?
    var justSignedUp = false

    // MARK: Outlets
    
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        setupValidator()
                
        attemptToPrefillForm()
        
        if justSignedUp { showEmailConfirmationAlert() }
    }
    
    // MARK: Validators
    
    func setupValidator() {
        validator.delegate = self
        
        validator.setActionButton(doneButton)

        validator.add(emailTextField, [.required, .email])
        
        validator.add(passwordTextField, [.required, .minLength(6)])
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
    
    // MARK: Form
    
    func disableForm() {
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        doneButton.isEnabled = false
        forgotPasswordButton.isEnabled = false
    }
    
    func enableForm() {
        emailTextField.isEnabled = true
        passwordTextField.isEnabled = true
        
        validator.revalidate()
    }
    
    // MARK: Networking
    
    func logInUser() {
        guard network.isReachable else {
            showOfflineAlertFor(operation: "log in")
            
            return
        }
        
        disableForm()

        showActivityIndicator()
        
        let route = AuthRoute.login(email: email!, password: password!)
        
        Session.shared.requestJSON(route) { response in
            DispatchQueue.main.async {
                self.hideActivityIndicator(replaceWith: self.doneButton)

                self.enableForm()
            }
            
            guard response.statusCode != 400 else {
                DispatchQueue.main.async { self.showInvalidCredentialsAlert() }
                
                return
            }
            
            DispatchQueue.main.async {
                self.storeUserDetails(response.data!)
                                
                self.navigateToDashboardScene()
                
                // Force loading of cache and store
                _ = Cache.shared
                
                _ = Store.shared
                
                SyncManager().start()
            }
        }
    }
    
    func forgotPassword() {
        guard network.isReachable else {
            showOfflineAlertFor(operation: "forgot password")
            
            return
        }
        
        disableForm()
        
        showActivityIndicator(for: forgotPasswordButton)
        
        let route = AuthRoute.forgot(email: email!)
        
        Session.shared.requestJSON(route) { response in
            DispatchQueue.main.async {
                self.hideActivityIndicator(for: self.forgotPasswordButton)

                self.enableForm()
            }

            guard response.statusCode != 422 else {
                if response.errors!["email"] != nil {
                    DispatchQueue.main.async { self.showInvalidEmailAlert() }
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self.showForgotPasswordLinkSentAlert()
            }
        }
    }
    
    // MARK: Keychain
    
    func attemptToPrefillForm() {
        emailTextField.text = Keychain.shared.get(.email)
        
        passwordTextField.text = signUpPassword
        
        validator.revalidate()
    }
    
    func storeUserDetails(_ data: JSON) {
        let id = "\(data["id"].int!)"
        let name = data["name"].string!
        let birthday = data["birthday"].string!
        let apiToken = data["api_token"].string!
        
        Keychain.shared.set(id, for: .id)
        Keychain.shared.set(email!, for: .email)
        Keychain.shared.set(name, for: .name)
        Keychain.shared.set(birthday, for: .birthday)
        Keychain.shared.set(apiToken, for: .apiToken)
    }
    
    // MARK: Navigation
    
    func navigateToDashboardScene() {
        if Keychain.shared.get(.permitReceivedAt) != nil {
            performSegue(withIdentifier: "userLoggedInSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "onboardingSegue", sender: nil)
        }
    }
    
    func navigateToMailBox() {
        let mailUrl = URL(string: "message://")!
        
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK: Alerting

extension LogInController: Alerting {
    func showInvalidCredentialsAlert() {
        let title = "Log In Failed"
        
        let message = "Log in failed due to a bad email and password combination or you have not verified your email."
        
        let cancelButton = CancelButton(title: "TRY AGAIN", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
    }
    
    func showEmailConfirmationAlert() {
        let title = "One More Step"
        
        let message = "An email has been sent to you. Please go to your inbox and click on the link. This will help verify your account and keep your details safe!"
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        let openMailButton = DefaultButton(title: "OPEN MAIL") { self.navigateToMailBox() }
        
        showAlert(title: title, message: message, buttons: [cancelButton, openMailButton])
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
    
    func showOfflineAlertFor(operation: String) {
        let title = "Offline Mode"
        
        let message = "You are currently offline and the \(operation) request can not be completed without being online. Connect online and try again."
        
        let cancelButton = CancelButton(title: "TRY AGAIN", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
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
