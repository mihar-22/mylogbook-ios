
import UIKit

class LogPrepareController: UIViewController {
    
    var cars = [Car]()
    
    var supervisors = [Supervisor]()
    
    let carPicker = UIPickerView()
    
    let supervisorPicker = UIPickerView()
    
    let pickerToolbar = UIToolbar()
    
    enum PickerView {
        case car, supervisor
    }
    
    var currentPicker: PickerView = .car
    
    // MARK: Outlets
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carRegistrationLabel: UILabel!
    @IBOutlet weak var carTypeImage: UIImageView!
    
    @IBOutlet weak var supervisorNameLabel: UILabel!
    @IBOutlet weak var supervisorLicenseLabel: UILabel!
    @IBOutlet weak var supervisorGenderImage: UIImageView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        navigationController!.navigationBar.restyle(.transparent)
        
        getCollections()
        
        setupPickers()
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
    
    // MARK: Cards
    
    func fillCard(car: Car) {
        carNameLabel.text = car.name
        carRegistrationLabel.text = car.registration
        // set type image here
    }
    
    func fillCard(supervisor: Supervisor) {
        supervisorNameLabel.text = supervisor.fullName
        supervisorLicenseLabel.text = supervisor.license
        // set gender image here
    }
    
    // MARK: Networking
    
    func getCollections() {
        getCollection() { (collection: [Car]) in
            self.cars.append(contentsOf: collection)
            
            self.fillCard(car: self.cars[0])
            
            self.carPicker.reloadAllComponents()
        }
        
        getCollection() { (collection: [Supervisor]) in
            self.supervisors.append(contentsOf: collection)
            
            self.fillCard(supervisor: self.supervisors[0])
            
            self.supervisorPicker.reloadAllComponents()
        }
    }
    
    func getCollection<Model: Resourceable>(completion: @escaping ([Model]) -> Void) {
        let route = ResourceRoute<Model>.index
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Model]>) in
            guard let collection = response.data else { return }
            
            completion(collection)
        }
    }
}

// MARK: UI Picker View - Data Source + Delegate

extension LogPrepareController: UIPickerViewDataSource, UIPickerViewDelegate {
    func setupPickers() {
        setup(picker: carPicker, tag: 0)

        setup(picker: supervisorPicker, tag: 1)
        
        setupPickerToolbar()
    }
    
    func setup(picker: UIPickerView, tag: Int) {
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
        (pickerView.tag == carPicker.tag) ? fillCard(car: cars[row]) : fillCard(supervisor: supervisors[row])
    }
}
