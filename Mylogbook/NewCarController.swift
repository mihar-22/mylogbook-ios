
import UIKit

// MARK: New Car Delegate

protocol NewCarDelegate {
    func carAdded(_ car: Car)
    
    func carUpdated(_ car: Car)
}

// MARK: New Car Controller

class NewCarController: UIViewController {
    
    var delegate: NewCarDelegate?
    
    var editingCar: Car?
    
    var isEditingCar: Bool { return (editingCar != nil) }
    
    let validator = Validator()
    
    var registration: String? { return registrationField.text }
    var make: String? { return makeField.text }
    var model: String? { return modelField.text }
    var type: String? { return typeField.text?.lowercased() }
    
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
    
    @IBOutlet weak var registrationField: TextField!
    @IBOutlet weak var makeField: TextField!
    @IBOutlet weak var modelField: TextField!
    @IBOutlet weak var typeField: TextField!
    
    @IBOutlet weak var registrationErrorLabel: UILabel!
    @IBOutlet weak var makeErrorLabel: UILabel!
    @IBOutlet weak var modelErrorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTextFields()
        
        setupTypePicker()
        
        setupValidator()
        
        if isEditingCar { setupEditing() }
    }
    
    // MARK: Editing
    
    func setupEditing() {
        navItem.title = "Edit Car"
        
        registrationField.text = editingCar!.registration
        makeField.text = editingCar!.make
        modelField.text = editingCar!.model
        typeField.text = editingCar!.type!.capitalized
        // set type image here
        
        validator.revalidate(updateUI: false)
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        if !isEditingCar { saveCar() }
        else { updateCar() }
    }
    
    // MARK: Text Field
    
    func setupTextFields() {
        registrationField.tag = 0
        registrationField.delegate = self

        makeField.tag = 1
        makeField.delegate = self
        
        modelField.tag = 2
        modelField.delegate = self
        
        typeField.tag = 3
        typeField.delegate = self
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(saveButton)
        
        validator.addField(registrationField, registrationErrorLabel, [.required, .alphaNum, .maxLength(max: 6)])
        
        validator.addField(makeField, makeErrorLabel, [.required, .alphaSpace, .maxLength(max: 50)])
        
        validator.addField(modelField, modelErrorLabel, [.required, .alphaNumSpace, .maxLength(max: 50)])
    }
    
    // MARK: Networking
    
    func saveCar() {
        let car = Car(registration: registration!, make: make!, model: model!, type: type!)
        
        let route = ResourceRoute<Car>.store(car)
        
        Session.shared.requestJSON(route) { response in
            car.id = response.data?["id"] as? Int
            
            self.delegate?.carAdded(car)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateCar() {
        editingCar!.registration = registration!
        editingCar!.make = make!
        editingCar!.model = model!
        editingCar!.type = type!
        
        let route = ResourceRoute<Car>.update(editingCar!)
        
        Session.shared.requestJSON(route) { response in
            self.delegate?.carUpdated(self.editingCar!)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Text Field Delegate

extension NewCarController: TextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension NewCarController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupTypePicker() {
        let typePicker = UIPickerView()
        
        typePicker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 150)
        
        typePicker.delegate = self
        typePicker.dataSource = self
        
        typeField.inputView = typePicker
        typeField.text = carTypes[0]
        
        // set type image here
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
        typeField.text = carTypes[row]
        
        // set type image here
        
        view.endEditing(true)
    }
}

