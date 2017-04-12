
import CoreStore
import DZNEmptyDataSet
import PopupDialog
import UIKit

class LogPrepareController: UIViewController {
    
    let validator = Validator()
    
    var cars = [Car]()
    
    var supervisors = [Supervisor]()
    
    var selectedCar = 0
    
    var selectedSupervisor = 0
    
    var isEmptyDataSet: Bool {
        return cars.count == 0 || supervisors.count == 0
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var carTextField: TextField!
    @IBOutlet weak var supervisorTextField: TextField!
    @IBOutlet weak var odometerTextField: TextField!
    
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupValidator()
        
        setupTypePickers()
        
        odometerTextField.setupValueFormatting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.emptyDataSetSource == nil { setupEmptyDataSet() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetch()
        
        startButton.isEnabled = !isEmptyDataSet
        
        scrollContentView.isHidden = isEmptyDataSet
        
        scrollView.reloadEmptyDataSet()

        if !isEmptyDataSet {
            updateCarViews()
            
            updateSupervisorViews()
        }
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
        
        let odometer = "\(Cache.shared.getOdometer(for: car) ??  0)"
        
        odometerTextField.valueText = odometer
        
        validator.revalidate()
    }
    
    func updateSupervisorViews() {
        let supervisor = supervisors[selectedSupervisor]
        
        supervisorTextField.text = supervisor.name
        
        validator.revalidate()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.setActionButton(startButton)
        
        validator.add(carTextField, [.required])
        validator.add(supervisorTextField, [.required])
        validator.add(odometerTextField, [.required, .numeric])
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRecordingSegue" {
            if let viewController = segue.destination as? LogRecordController {
                let odometer = Int32(odometerTextField.value)
                
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

// MARK: Empty Data Set

extension LogPrepareController: EmptyView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func setupEmptyDataSet() {
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
        scrollView.reloadEmptyDataSet()
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-log")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return isEmptyDataSet
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(title: "Not Ready")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(description: "You'll be needing a car and supervisor")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -20
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
        
        carTextField.inputView = typePicker
    }
    
    func setupSupervisorPicker() {
        let typePicker = UIPickerView()

        typePicker.tag = supervisorTextField.tag
        typePicker.delegate = self
        typePicker.dataSource = self
        
        supervisorTextField.inputView = typePicker
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
