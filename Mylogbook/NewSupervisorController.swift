
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

    var firstName: String? { return firstNameTextField.text }
    var lastName: String? { return lastNameTextField.text }
    var license: String? { return licenseTextField.text }
    var gender: String? { return genderTextField.text?.lowercased() }
    
    let genders = ["Male", "Female"]
    
    // MARK: Outlets
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var genderImage: UIImageView!
    
    @IBOutlet weak var firstNameTextField: TextField!
    @IBOutlet weak var lastNameTextField: TextField!
    @IBOutlet weak var licenseTextField: TextField!
    @IBOutlet weak var genderTextField: TextField!
    
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
        
        firstNameTextField.text = editingSupervisor!.firstName
        lastNameTextField.text = editingSupervisor!.lastName
        licenseTextField.text = editingSupervisor!.license
        genderTextField.text = editingSupervisor!.gender!.capitalized
        // set gender image here
        
        validator.revalidate()
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
        licenseTextField.field.tag = 0
        licenseTextField.field.delegate = self
        
        firstNameTextField.field.tag = 1
        firstNameTextField.field.delegate = self
        
        lastNameTextField.field.tag = 2
        lastNameTextField.field.delegate = self
        
        genderTextField.field.tag = 3
        genderTextField.field.delegate = self
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(saveButton)
        
        validator.add(firstNameTextField, [.required, .alpha, .maxLength(max: 50)])
        
        validator.add(lastNameTextField, [.required, .alpha, .maxLength(max: 50)])
        
        validator.add(licenseTextField, [.required, .alphaNum, .maxLength(max: 10)])
    }
    
    // MARK: Networking
    
    func saveSupervisor() {
        let supervisor = Supervisor(firstName: firstName!, lastName: lastName!, license: license!, gender: gender!)
        
        let route = ResourceRoute<Supervisor>.store(supervisor)
        
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
        
        let route = ResourceRoute<Supervisor>.update(editingSupervisor!)
        
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
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.restyle(.normal)
        toolbar.addDoneButton(target: self, action: #selector(pickerDoneHandler(_:)))
        
        genderTextField.field.inputView = genderPicker
        genderTextField.field.inputAccessoryView = toolbar

        genderTextField.text = genders[0]
        // set gender image here
    }
    
    func pickerDoneHandler(_ sender: UIBarButtonItem) {
        let _ = genderTextField.field.resignFirstResponder()
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
        genderTextField.text = genders[row]
        
        // set gender image here
    }
}

