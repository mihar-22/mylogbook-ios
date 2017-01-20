
import UIKit

// MARK: New Supervisor Delegate

protocol NewSupervisorDelegate {
    func supervisorAdded(_ supervisor: Supervisor)
    
    func supervisorUpdated(_ supervisor: Supervisor)
}

// MARK: New supervisor Controller

class NewSupervisorController: UIViewController {
    
    var delegate: NewSupervisorDelegate?
    
    var editingSupervisor: Supervisor?
    
    var isEditingSupervisor: Bool { return (editingSupervisor != nil) }
    
    let validator = Validator()

    var firstName: String? { return firstNameField.text }
    var lastName: String? { return lastNameField.text }
    var license: String? { return licenseField.text }
    var gender: String? { return genderField.text?.lowercased() }
    var avatar: Int = 1
    
    let genders = ["Male", "Female"]
    
    // MARK: Outlets
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var firstNameField: TextField!
    @IBOutlet weak var lastNameField: TextField!
    @IBOutlet weak var licenseField: TextField!
    @IBOutlet weak var genderField: TextField!
    
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var licenseErrorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTextFields()
        
        setupGenderPicker()
        
        setupValidator()
        
        if isEditingSupervisor { setupEditing() }
    }
    
    // MARK: Editing
    
    func setupEditing() {
        navItem.title = "Edit Supervisor"
        
        firstNameField.text = editingSupervisor!.firstName
        lastNameField.text = editingSupervisor!.lastName
        licenseField.text = editingSupervisor!.license
        genderField.text = editingSupervisor!.gender!.capitalized
        // set avatar image here
        
        validator.forceValidateAllFields()
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        if !isEditingSupervisor { saveSupervisor() }
        else { updateSupervisor() }
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        licenseField.tag = 0
        licenseField.delegate = self
        
        firstNameField.tag = 1
        firstNameField.delegate = self
        
        lastNameField.tag = 2
        lastNameField.delegate = self
        
        genderField.tag = 3
        genderField.delegate = self
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(saveButton)
        
        validator.addField(firstNameField, firstNameErrorLabel, [.required, .alpha, .maxLength(max: 50)])
        
        validator.addField(lastNameField, lastNameErrorLabel, [.required, .alpha, .maxLength(max: 50)])
        
        validator.addField(licenseField, licenseErrorLabel, [.required, .alphaNum, .maxLength(max: 10)])
    }
    
    // MARK: Networking
    
    func saveSupervisor() {
        let supervisor = Supervisor(firstName: firstName!,
                                    lastName: lastName!,
                                    license: license!,
                                    gender: gender!,
                                    avatar: avatar)
        
        let route = SupervisorRoute.store(supervisor)
        
        Session.shared.requestJSON(route) { response in
            supervisor.id = response.data?["id"] as? Int
            
            self.delegate?.supervisorAdded(supervisor)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateSupervisor() {
        editingSupervisor!.firstName = firstName!
        editingSupervisor!.lastName = lastName!
        editingSupervisor!.license = license!
        editingSupervisor!.gender = gender!
        editingSupervisor!.avatar = avatar
        
        let route = SupervisorRoute.update(editingSupervisor!)
        
        Session.shared.requestJSON(route) { response in
            self.delegate?.supervisorUpdated(self.editingSupervisor!)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Text Field Delegate

extension NewSupervisorController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension NewSupervisorController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupGenderPicker() {
        let genderPicker = UIPickerView()
        
        genderPicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        genderField.inputView = genderPicker
        genderField.text = genders[0]
        
        // set avatar image here
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genders[row]
        
        // set avatar image here
        
        view.endEditing(true)
    }
}

