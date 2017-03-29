
import UIKit

// MARK: Car Controller

class CarController: UIViewController {
    
    var car: Car?
    
    var isEdit: Bool { return (car != nil) }
    
    let validator = Validator()
    
    var registration: String? { return registrationTextField.text }
    var name: String? { return nameTextField.text }
    var type: String? { return typeTextField.text?.lowercased() }
    
    let carTypes = [
        "Sedan",
        "SUV",
        "Sports",
        "Off Road",
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
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var typeTextField: TextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTypePicker()
        
        setupValidator()
        
        if isEdit { setupEditing() }
    }
    
    // MARK: Editing
    
    func setupEditing() {
        navItem.title = "Edit Car"
        
        registrationTextField.text = car!.registration
        nameTextField.text = car!.name
        typeTextField.text = car!.type.capitalized
        typeImage.image = car!.image(ofSize: .display)
        
        validator.revalidate()
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        CarStore.add(car, registration: registration!, name: name!, type: type!)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(saveButton)
        
        validator.add(registrationTextField, [.required, .alphaNum, .maxLength(6)])
        
        validator.add(nameTextField, [.required, .maxLength(50)])
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension CarController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupTypePicker() {
        let typePicker = UIPickerView()

        typePicker.delegate = self
        typePicker.dataSource = self
        
        typeTextField.text = carTypes[0]
        typeTextField.inputView = typePicker
        
        setDisplayImage()
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
        
        setDisplayImage()
    }
   
    func setDisplayImage() {
        let type = self.type!.replacingOccurrences(of: " ", with: "-")
        
        let name = "car-\(type)-display"
        
        typeImage.image = UIImage(named: name)
    }
}

