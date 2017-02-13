
import UIKit

// MARK: Car Controller

class CarController: UIViewController {
    
    var car: Car?
    
    var isEdit: Bool { return (car != nil) }
    
    let validator = Validator()
    
    var registration: String? { return registrationTextField.text }
    var make: String? { return makeTextField.text }
    var model: String? { return modelTextField.text }
    var type: String? { return typeTextField.text?.lowercased() }
    
    let carTypes = [
        "Sedan",
        "SUV",
        "Sports",
        "4WD",
        "Coupe",
        "Convertible",
        "Wagon",
        "Ute",
        "Micro",
        "Hatchback",
        "Van"
    ]
    
    // MARK: Outlets
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var typeImage: UIImageView!
    
    @IBOutlet weak var registrationTextField: TextField!
    @IBOutlet weak var makeTextField: TextField!
    @IBOutlet weak var modelTextField: TextField!
    @IBOutlet weak var typeTextField: TextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTextFields()
        
        setupTypePicker()
        
        setupValidator()
        
        if isEdit { setupEditing() }
    }
    
    // MARK: Editing
    
    func setupEditing() {
        navItem.title = "Edit Car"
        
        registrationTextField.text = car!.registration
        makeTextField.text = car!.make
        modelTextField.text = car!.model
        typeTextField.text = car!.type!.capitalized
        // set type image here
        
        validator.revalidate()
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        CarStore.add(car, registration: registration!, make: make!, model: model!, type: type!)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        registrationTextField.field.tag = 0
        registrationTextField.field.delegate = self

        makeTextField.field.tag = 1
        makeTextField.field.delegate = self
        
        modelTextField.field.tag = 2
        modelTextField.field.delegate = self
        
        typeTextField.field.tag = 3
        typeTextField.field.delegate = self
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(saveButton)
        
        validator.add(registrationTextField, [.required, .alphaNum, .maxLength(max: 6)])
        
        validator.add(makeTextField, [.required, .alphaSpace, .maxLength(max: 50)])
        
        validator.add(modelTextField, [.required, .alphaNumSpace, .maxLength(max: 50)])
    }
}

// MARK: Text Field Delegate

extension CarController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension CarController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupTypePicker() {
        let typePicker = UIPickerView()
        typePicker.delegate = self
        typePicker.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.restyle(.normal)
        toolbar.addDoneButton(target: self, action: #selector(pickerDoneHandler(_:)))
        
        typeTextField.text = carTypes[0]
        typeTextField.field.inputView = typePicker
        typeTextField.field.inputAccessoryView = toolbar
        
        // set type image here
    }
    
    func pickerDoneHandler(_ sender: UIBarButtonItem) {
       let _ = typeTextField.field.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return carTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return carTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = carTypes[row]
        
        // set type image here
    }
}

