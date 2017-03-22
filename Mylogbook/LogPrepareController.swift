
import CoreStore
import PopupDialog
import UIKit

class LogPrepareController: UIViewController {
    
    var cars = [Car]()
    
    var supervisors = [Supervisor]()
    
    // MARK: Pickers
    
    enum PickerView {
        case car, supervisor
    }
    
    let carPicker = UIPickerView()
    
    let supervisorPicker = UIPickerView()
    
    let pickerToolbar = UIToolbar()
    
    var currentPicker: PickerView = .car
    
    var selectedCar: Car {
        return cars[carPicker.selectedRow(inComponent: 0)]
    }
    
    var selectedSupervisor: Supervisor {
        return supervisors[supervisorPicker.selectedRow(inComponent: 0)]
    }
    
    // MARK: Odometer
    
    var odometerAlert: OdometerAlert!
    
    var doneButton: DefaultButton!
        
    // MARK: Outlets
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carRegistrationLabel: UILabel!
    @IBOutlet weak var carTypeImage: UIImageView!
    
    @IBOutlet weak var supervisorNameLabel: UILabel!
    @IBOutlet weak var supervisorGenderImage: UIImageView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetch()
    }
    
    // MARK: Fetch
    
    func fetch() {
        fetchCars()
        
        fetchSupervisors()
    }
    
    func fetchCars() {
        cars = Store.shared.stack.fetchAll(From<Car>(),
                                           Where("deletedAt == nil"),
                                           OrderBy(.ascending("make")))!
        
        carPicker.reloadAllComponents()
        
        if cars.first != nil { configureCard(car: cars.first!) }
    }
    
    func fetchSupervisors() {
        supervisors = Store.shared.stack.fetchAll(From<Supervisor>(),
                                                  Where("deletedAt == nil"),
                                                  OrderBy(.ascending("firstName")))!
        
        supervisorPicker.reloadAllComponents()
        
        if supervisors.first != nil { configureCard(supervisor: supervisors.first!) }
    }
    
    // MARK: Actions
    
    @IBAction func didTapCarCard(_ sender: UILongPressGestureRecognizer) {
        longPressHandler(sender)
    }
    
    @IBAction func didTapSupervisorCard(_ sender: UILongPressGestureRecognizer) {
        longPressHandler(sender)
    }
    
    func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        let view = sender.view!
        
        currentPicker = (view.tag == 0) ? .car : .supervisor
        
        switch sender.state {
        case .began:
            view.backgroundColor = UIColor.lightGray
        case .ended:
            view.backgroundColor = UIColor.white
            
            showPicker()
        default:
            break
        }
    }
    
    @IBAction func didTapStart(_ sender: UIBarButtonItem) {
        showOdometerAlert()
    }
    
    // MARK: Cards
    
    func configureCard(car: Car) {
        carNameLabel.text = car.name
        carRegistrationLabel.text = car.registration
        // set type image here
    }
    
    func configureCard(supervisor: Supervisor) {
        supervisorNameLabel.text = supervisor.fullName
        // set gender image here
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRecordingSegue" {
            if let viewController = segue.destination as? LogRecordController {
                let odometer = self.odometerAlert.odometerValue
                                
                let trip = Trip()
                
                trip.odometer = odometer
                
                trip.car = selectedCar
                
                trip.supervisor = selectedSupervisor
                
                Cache.shared.set(odometer: odometer, for: selectedCar)

                Cache.shared.save()
                
                viewController.trip = trip
            }
        }
    }
}

// MARK: Alerting

extension LogPrepareController: Alerting {
    func setupOdometerAlert() {
        odometerAlert = OdometerAlert(nibName: "OdometerAlert", bundle: nil)
        
        // Force view hierarchy to load
        let _ = odometerAlert.view
        
        odometerAlert.validator.delegate = self
    }
    
    func showOdometerAlert() {
        setupOdometerAlert()
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        doneButton = DefaultButton(title: "DONE") {
            self.performSegue(withIdentifier: "startRecordingSegue", sender: nil)
        }
        
        let odometer = (Cache.shared.getOdometer(for: selectedCar) ?? 0)
        
        odometerAlert.odometerText = String(odometer)
        
        odometerAlert.validator.revalidate()

        self.showCustomAlert(viewController: odometerAlert, buttons: [cancelButton, doneButton])
    }
}

// MARK: Validator Delegate

extension LogPrepareController: ValidatorDelegate {
    func validationSuccessful(_ textField: TextField) {
        isDoneButton(enabled: true)
    }
    
    func validationFailed(_ textField: TextField) {
        isDoneButton(enabled: false)
    }
    
    func isDoneButton(enabled isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        
        let style: DefaultButtonStyle = (isEnabled) ? .normal : .disabled
        
        doneButton.restyle(style)
    }
}

// MARK: Picker View - Data Source + Delegate

extension LogPrepareController: UIPickerViewDataSource, UIPickerViewDelegate {
    func setupPickers() {
        setup(carPicker, tag: 0)

        setup(supervisorPicker, tag: 1)
        
        setupPickerToolbar()
    }
    
    func setup(_ picker: UIPickerView, tag: Int) {
        let height: CGFloat = 180
        
        picker.backgroundColor = UIColor.white
        picker.dataSource = self
        picker.delegate = self
        picker.tag = tag
        picker.isHidden = true
        picker.frame = CGRect(x: 0,
                              y: view.bounds.height - tabBarController!.tabBar.frame.height - height,
                              width: view.bounds.width,
                              height: height)
        
        view.addSubview(picker)
    }
    
    func setupPickerToolbar() {
        let picker = carPicker
        
        pickerToolbar.restyle(.normal)
        pickerToolbar.addDoneButton(target: self, action: #selector(pickerDoneHandler(_:)))
        pickerToolbar.isHidden = true
        pickerToolbar.frame = CGRect(x: 0,
                               y: picker.frame.minY - pickerToolbar.frame.height,
                               width: view.bounds.width,
                               height: pickerToolbar.frame.height)
        
        view.addSubview(pickerToolbar)
    }
    
    func pickerDoneHandler(_ sender: UIBarButtonItem) {
        hidePickers()
    }
    
    func showPicker() {
        let isCarPickerHidden = (currentPicker == .car) ? false : true
        
        carPicker.isHidden = isCarPickerHidden
        
        supervisorPicker.isHidden = !isCarPickerHidden
        
        pickerToolbar.isHidden = false
    }
    
    func hidePickers() {
        carPicker.isHidden = true
        
        supervisorPicker.isHidden = true
        
        pickerToolbar.isHidden = true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerView.tag == carPicker.tag) ? cars.count : supervisors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickerView.tag == carPicker.tag) ? cars[row].name : supervisors[row].fullName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        (pickerView.tag == carPicker.tag) ? configureCard(car: cars[row]) : configureCard(supervisor: supervisors[row])
    }
}
