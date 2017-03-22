
import Alamofire
import UIKit
import PopupDialog

class SignUpController: UIViewController {
    let validator = Validator()
    
    let network = NetworkReachabilityManager(host: Env.MLB_API_BASE)!
    
    var name: String? { return nameTextField.text }
    var email: String? { return emailTextField.text }
    var password: String? { return passwordTextField.text }
    var birthday: String?
    
    // MARK: Outlets
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var birthdayTextField: TextField!
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        setupValidator()
        
        setupTextFields()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(createButton)

        validator.add(nameTextField, [.required, .alphaSpace, .maxLength(max: 50)])
        
        validator.add(emailTextField, [.required, .email])
        
        validator.add(passwordTextField, [.required, .minLength(min: 6)])
        
        validator.add(birthdayTextField, [.required])
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        nameTextField.field.tag = 0
        nameTextField.field.delegate = self
        
        emailTextField.field.tag = 1
        emailTextField.field.delegate = self
        
        passwordTextField.field.tag = 2
        passwordTextField.field.delegate = self
     
        birthdayTextField.field.tag = 3
        birthdayTextField.field.delegate = self
        
        setupBirthdayDatePicker()
    }
    
    func setupBirthdayDatePicker() {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -80, to: Date())

        picker.maximumDate = Calendar.current.date(byAdding: .year, value: -15, to: Date())
        
        picker.addTarget(self, action: #selector(didChangeBirthday(_:)), for: .valueChanged)
        
        birthdayTextField.field.inputView = picker
    }

    // MARK: Actions

    @IBAction func didTapCreate(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        registerUser()
    }

    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func didChangeBirthday(_ sender: UIDatePicker) {
        birthday = sender.date.utc(format: .date)

        birthdayTextField.text = sender.date.local(date: .long, time: .none)
        
        validator.revalidate()
    }

    // MARK: Networking
    
    func registerUser() {
        guard network.isReachable else {
            showOfflineAlertFor(operation: "create account")
            
            return
        }
        
        let route = AuthRoute.register(name: name!,
                                       email: email!,
                                       password: password!,
                                       birthday: birthday!)
        
        Session.shared.requestJSON(route) { response in
            guard response.statusCode != 422 else {
                if response.errors!["email"] != nil {
                    DispatchQueue.main.async { self.showEmailTakenAlert() }
                }
                
                return
            }
            
            DispatchQueue.main.async {
                Keychain.shared.set(self.email!, for: .email)

                self.showEmailConfirmationAlert()
            }
        }
    }
    
    // MARK: Navigation
    
    func navigateToLoginScene() {
        performSegue(withIdentifier: "logInSegue", sender: self)
    }
    
    func navigateToMailBox() {
        let mailUrl = URL(string: "message://")!
        
        if UIApplication.shared.canOpenURL(mailUrl) {
            UIApplication.shared.open(mailUrl, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logInSegue" {
            if let controller = segue.destination as? LogInController {
                controller.signUpPassword = password!
            }
        }
    }
}

// MARK: Alerting

extension SignUpController: Alerting {
    func showEmailTakenAlert() {
        let title = "Email Taken"
        
        let message = "This email is already taken. Try logging in or forgot password on the log in page."
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        let logInButton = DefaultButton(title: "LOG IN") { self.navigateToLoginScene() }
        
        showAlert(title: title, message: message, buttons: [cancelButton, logInButton])
    }
    
    func showEmailConfirmationAlert() {        
        let title = "One More Step"
        
        let message = "An email has been sent to you. Please go to your inbox and click on the link. This will help verify your account and keep your details safe!"
        
        let cancelButton = CancelButton(title: "LOG IN") { self.navigateToLoginScene() }
        
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

// MARK: Text Field Delegate

extension SignUpController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}
