
import UIKit

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
        attemptToPrefillForm()

        setupValidator()
        
        setupTextFields()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.delegate = self
        
        validator.setActionButton(doneButton)

        validator.addField(emailTextField, emailErrorLabel, [.required, .email])
        
        validator.addField(passwordTextField, passwordErrorLabel, [.required, .minLength(min: 6)])
        
        validator.forceValidateAllFields()
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
    
    // MARK: Alerts
    
    func showInvalidCredentialsAlert() {
        let alert = Alert()
        
        alert.addCloseButton("TRY AGAIN")
        
        alert.showError("Log In Failed", subTitle: "\nLog in failed due to a bad email and password combination OR you have not verified your email.\n")
    }
    
    func showInvalidEmailAlert() {
        let alert = Alert()
        
        alert.addCloseButton("TRY AGAIN")
        
        alert.showError("Bad Email", subTitle: "\nA reset link could not be sent because no account exists with this email.\n")
    }
    
    func showForgotPasswordLinkSentAlert() {
        let alert = Alert()
        
        alert.addPositiveButton("OPEN MAIL") { self.navigateToMailBox() }
        
        alert.addCloseButton("CLOSE")
        
        alert.showError("Reset Link Sent", subTitle: "\nAn email has been sent to you. Please go to your inbox and click on the link. The link will provide you with a form to reset your password.\n")
    }
    
    // MARK: Keychain
    
    func attemptToPrefillForm() {
        emailTextField.text = Keychain.shared.email ?? ""
        
        passwordTextField.text = Keychain.shared.password ?? ""
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

// MARK: Text Field Delegate

extension LogInController: TextFieldDelegate {    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: Validator Delegate

extension LogInController: ValidatorDelegate {
    func validationSuccessful(_ textField: TextField) {
        if textField.tag == 0 { forgotPasswordButton.isEnabled = true }
    }
    
    func validationFailed(_ textField: TextField) {
        if textField.tag == 0 { forgotPasswordButton.isEnabled = false }
    }
}
