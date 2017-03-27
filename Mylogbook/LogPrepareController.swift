
import CoreStore
import PopupDialog
import UIKit

class LogPrepareController: UIViewController {
    
    let validator = Validator()
    
    var cars = [Car]()
    
    var supervisors = [Supervisor]()
    
    var selectedCar = 0
    
    var selectedSupervisor = 0
    
    // MARK: Outlets
    
    @IBOutlet weak var carTypeImage: UIImageView!
    @IBOutlet weak var supervisorAvatar: UIImageView!
    
    @IBOutlet weak var carTextField: TextField!
    @IBOutlet weak var supervisorTextField: TextField!
    @IBOutlet weak var odometerTextField: TextField!
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        fetch()
        
        setupValidator()
        
        setupTextFields()
        
        setupTypePickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isViewLoaded { fetch() }
    }
    
    // MARK: Fetch
    
    func fetch() {
        cars = Store.shared.stack.fetchAll(From<Car>(),
                                           Where("deletedAt == nil"),
                                           OrderBy(.ascending("name")))!
        
        supervisors = Store.shared.stack.fetchAll(From<Supervisor>(),
                                                  Where("deletedAt == nil"),
                                                  OrderBy(.ascending("name")))!
    }
    
    // MARK: Updates
    
    func updateCarViews() {
        let car = cars[selectedCar]
        
        carTextField.text = car.name

        // set car type image
        
        let odometer = "\(Cache.shared.getOdometer(for: car) ??  0)"
        
        odometerTextField.field.valueText = odometer
        
        validator.revalidate()
    }
    
    func updateSupervisorViews() {
        let supervisor = supervisors[selectedSupervisor]
        
        supervisorTextField.text = supervisor.name
        
        // set supervisor avatar image
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(startButton)
        
        validator.add(odometerTextField, [.required, .numeric])
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRecordingSegue" {
            if let viewController = segue.destination as? LogRecordController {
                let odometer = odometerTextField.field.value
                
                let car = cars[selectedCar]
                
                let supervisor = supervisors[selectedSupervisor]
                
                let trip = Trip()
                
                trip.odometer = odometer

                trip.car = car
                
                trip.supervisor = supervisor
                
                Cache.shared.set(odometer: odometer, for: car)

                Cache.shared.save()
                
                viewController.trip = trip
            }
        }
    }
}

// MARK: Text Field Delegate

extension LogPrepareController: TextFieldDelegate {
    func setupTextFields() {
        carTextField.tag = 0
        carTextField.field.delegate = self
        
        supervisorTextField.tag = 1
        supervisorTextField.field.delegate = self
        
        odometerTextField.tag = 2
        odometerTextField.field.delegate = self
        odometerTextField.field.setupValueFormatting()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldShouldReturnHandler(textField)
    }
}

// MARK: UI Picker View - Delegate + Data Source

extension LogPrepareController: UIPickerViewDelegate, UIPickerViewDataSource {
    func setupTypePickers() {
        setupCarPicker()
        
        setupSupervisorPicker()
    }
    
    func setupCarPicker() {
        let typePicker = UIPickerView()
        
        typePicker.tag = carTextField.tag
        typePicker.delegate = self
        typePicker.dataSource = self
        
        carTextField.field.inputView = typePicker
        
        updateCarViews()
    }
    
    func setupSupervisorPicker() {
        let typePicker = UIPickerView()

        typePicker.tag = supervisorTextField.tag
        typePicker.delegate = self
        typePicker.dataSource = self
        
        supervisorTextField.field.inputView = typePicker
        
        updateSupervisorViews()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView.tag == carTextField.tag) ? cars.count : supervisors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickerView.tag == carTextField.tag) ? cars[row].name : supervisors[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == carTextField.tag {
            selectedCar = row
            
            updateCarViews()
        }
        else if pickerView.tag == supervisorTextField.tag {
            selectedSupervisor = row
            
            updateSupervisorViews()
        }
    }
}
