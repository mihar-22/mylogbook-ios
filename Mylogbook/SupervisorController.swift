
import UIKit

// MARK: Supervisor Controller

class SupervisorController: UIViewController {
    
    var supervisor: Supervisor?
    
    var isEdit: Bool { return (supervisor != nil) }
    
    let validator = Validator()

    var firstName: String? { return firstNameTextField.text }
    var lastName: String? { return lastNameTextField.text }
    var gender: String? { return genderTextField.text?.lowercased() }
    var isAccredited: Bool { return accreditedSwitch.isOn }
    
    let genders = ["Male", "Female"]
    
    // MARK: Outlets
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var genderImage: UIImageView!
    
    @IBOutlet weak var firstNameTextField: TextField!
    @IBOutlet weak var lastNameTextField: TextField!
    @IBOutlet weak var genderTextField: TextField!
    @IBOutlet weak var accreditedSwitch: UISwitch!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTextFields()
        
        setupGenderPicker()
        
        setupValidator()
        
        accreditedSwitch.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        
        if isEdit { setupEditing() }
    }
    
    // MARK: Editing
    
    func setupEditing() {
        navItem.title = "Edit Supervisor"
        
        firstNameTextField.text = supervisor!.firstName
        lastNameTextField.text = supervisor!.lastName
        genderTextField.text = supervisor!.gender.capitalized
        accreditedSwitch.setOn(supervisor!.isAccredited, animated: true)
        // set gender image here
        
        validator.revalidate()
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        SupervisorStore.add(supervisor,
                            firstName: firstName!,
                            lastName: lastName!,
                            gender: gender!,
                            isAccredited: isAccredited)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didChangeAccreditedValueFor(_ sender: UISwitch) {
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
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
    }
}

// MARK: Text Field Delegate

extension SupervisorController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension SupervisorController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupGenderPicker() {
        let genderPicker = UIPickerView()

        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        genderTextField.field.inputView = genderPicker

        genderTextField.text = genders[0]
        // set gender image here
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

