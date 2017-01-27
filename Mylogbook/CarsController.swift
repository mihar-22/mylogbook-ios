
import UIKit
import PopupDialog

class CarsController: UIViewController, ResourceCollectionViewable {
    
    var collection = [Car]()
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionTable: UITableView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        viewDidLoadHandler()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NewCarController {
            viewController.delegate = self
            
            if segue.identifier == "editCarSegue" {
                if let selectedCell = sender as? CarCell {
                    let indexPath = collectionTable.indexPath(for: selectedCell)!
                    
                    let car = collection[indexPath.row]
                    
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
        
        let cancelButton = CancelButton(title: "CANCEL") { self.collectionTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") { self.deleteModel(indexPath: indexPath) }
            
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: New Car Delegate

extension CarsController: NewCarDelegate {
    func carAdded(_ car: Car) {
        addToTable(car)
    }
    
    func carUpdated(_ car: Car) {
        collectionTable.reloadData()
    }
}

// MARK: Table View - Data Source + Delegate

extension CarsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collectionTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: CarCell, indexPath: IndexPath) {
        let car = collection[indexPath.row]
        
        cell.nameLabel.text = car.name
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
