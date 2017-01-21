
import UIKit
import PopupDialog

class CarsController: UIViewController {
    
    var cars = [Car]()
    
    // MARK: Outlets
    
    @IBOutlet weak var carsTable: UITableView!
    
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTable()
        
        getCars()
    }
    
    // MARK: Networking
    
    func getCars() {
        let route = ResourceRoute<Car>.index
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Car]>) in
            guard let carCollection = response.data else { return }
            
            self.carsTable.beginUpdates()
            
            for car in carCollection { self.addCarToTable(car) }
            
            self.carsTable.endUpdates()
        }
    }
    
    func deleteCar(indexPath: IndexPath) {
        let car = cars[indexPath.row]
        
        let route = ResourceRoute<Car>.destroy(car)
        
        Session.shared.requestJSON(route) { _ in
            self.removeCarFromTable(indexPath: indexPath)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NewCarController {
            viewController.delegate = self
            
            if segue.identifier == "editCarSegue" {
                if let selectedCell = sender as? CarCell {
                    let indexPath = carsTable.indexPath(for: selectedCell)!
                    
                    let car = cars[indexPath.row]
                    
                    viewController.editingCar = car
                }
            }
        }
    }
}

// MARK: Alertable

extension CarsController: Alertable {
    func showCarDeletionPrompt(indexPath: IndexPath) {
        let title = "Delete Car"
        
        let message = "Are you sure you want to delete this car permanently?"
        
        let cancelButton = CancelButton(title: "CANCEL") { self.carsTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") { self.deleteCar(indexPath: indexPath) }
            
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: New Car Delegate

extension CarsController: NewCarDelegate {
    func carAdded(_ car: Car) {
        addCarToTable(car)
    }
    
    func carUpdated(_ car: Car) {
        carsTable.reloadData()
    }
}

// MARK: Table View - Data Source + Delegate

extension CarsController: UITableViewDataSource, UITableViewDelegate {
    func setupTable() {
        carsTable.dataSource = self

        carsTable.delegate = self
        
        carsTable.tableFooterView = UIView()
    }
    
    func addCarToTable(_ car: Car) {
        cars.append(car)
        
        carsTable.insertRows(at: [IndexPath(row: self.cars.count - 1, section: 0)], with: .automatic)
    }
    
    func removeCarFromTable(indexPath: IndexPath) {
        self.cars.remove(at: indexPath.row)
        
        self.carsTable.deleteRows(at: [indexPath], with: .automatic)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: CarCell, indexPath: IndexPath) {
        let car = cars[indexPath.row]
        
        cell.nameLabel.text = "\(car.make!) \(car.model!)"
        cell.registrationLabel.text = car.registration!
        // set typeImage here
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            self.showCarDeletionPrompt(indexPath: indexPath)
        }
        
        return [delete]
    }
}
