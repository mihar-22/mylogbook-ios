
import UIKit
import PopupDialog

class SignUpController: UIViewController {
    let validator = Validator()
    
    var name: String? { return nameTextField.text }
    var email: String? { return emailTextField.text }
    var password: String? { return passwordTextField.text }
    
    // MARK: Outlets
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    
    @IBOutlet weak var nameErrorlabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        setupValidator()
        
        setupTextFields()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(createButton)

        validator.addField(nameTextField, nameErrorlabel, [.required, .alphaSpace, .maxLength(max: 50)])
        
        validator.addField(emailTextField, emailErrorLabel, [.required, .email])
        
        validator.addField(passwordTextField, passwordErrorLabel, [.required, .minLength(min: 6)])
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        nameTextField.tag = 0
        nameTextField.delegate = self
        
        emailTextField.tag = 1
        emailTextField.delegate = self
        
        passwordTextField.tag = 2
        passwordTextField.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func didTapCreate(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        registerUser()
    }

    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Networking
    
    func registerUser() {
        let route = AuthRoute.register(name: name!, email: email!, password: password!)
        
        Session.shared.requestJSON(route) { response in
            guard response.statusCode != 422 else {
                if response.errors!["email"] != nil { self.showEmailTakenAlert() }
                
                return
            }
            
            self.showEmailConfirmationAlert()
        }
    }
    
    // MARK: Keychain
    
    func storeUserDetails() {
        Keychain.shared.name = name!
        Keychain.shared.email = email!
        Keychain.shared.password = password!
    }
    
    // MARK: Navigation
    
    func navigateToLoginScene() {
        storeUserDetails()

        performSegue(withIdentifier: "logInSegue", sender: self)
    }
    
    func navigateToMailBox() {
        let mailUrl = URL(string: "message://")!
        
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl, options: [:], completionHandler: nil)
        }
    }
}

// MARK: Alertable

extension SignUpController: Alertable {
    func showEmailTakenAlert() {
        let title = "Email Taken"
        
        let message = "This email is already taken, try logging in or forgot password on the log in page."
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        let logInButton = DefaultButton(title: "LOG IN") { self.navigateToLoginScene() }
        
        showAlert(title: title, message: message, buttons: [cancelButton, logInButton])
    }
    
    func showEmailConfirmationAlert() {        
        let title = "One More Step"
        
        let message = "An email has been sent to you. Please go to your inbox and click on the link. This will help verify your account and keep your details safe!"
        
        let cancelButton = CancelButton(title: "LOGIN") { self.navigateToLoginScene() }
        
        let openMailButton = DefaultButton(title: "OPEN MAIL") { self.navigateToMailBox() }
        
        showAlert(title: title, message: message, buttons: [cancelButton, openMailButton])
    }
}

// MARK: Text Field Delegate

extension SignUpController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}
