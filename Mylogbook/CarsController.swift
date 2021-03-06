
import UIKit
import CoreStore
import DZNEmptyDataSet
import PopupDialog

class CarsController: UIViewController {
    
    var cars = Store.shared.stack.monitorList(From<Car>(),
                                              Where<Car>("deletedAt = nil"),
                                              OrderBy<Car>(.ascending("name")))
    
    // MARK: Outlets
    
    @IBOutlet weak var carsTable: UITableView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        cars.addObserver(self)
        
        setupEmptyDataSet()
    }
    
    deinit {
        cars.removeObserver(self)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        
        if let viewController = destinationNavigationController.topViewController as? CarController {
            if segue.identifier == "editCarSegue" {
                if let selectedCell = sender as? CarCell {
                    let indexPath = carsTable.indexPath(for: selectedCell)!
                    
                    let car = cars[indexPath.row]
                    
                    viewController.car = car
                }
            }
        }
    }
}

// MARK: Alerting

extension CarsController: Alerting {
    func showDeletionPrompt(for index: Int) {
        let title = "Delete Car"
        
        let message = "Are you sure you want to delete this car permanently?"
        
        let cancelButton = CancelButton(title: "CANCEL") { self.carsTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") {
            let car = self.cars[index]
            
            CarStore.delete(car)
        }
            
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: Empty Data Set

extension CarsController: EmptyView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func setupEmptyDataSet() {
        carsTable.emptyDataSetSource = self
        carsTable.emptyDataSetDelegate = self
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-cars")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(title: "No Cars")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(description: "Cars you will be driving on trips will be here")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return emptyViewButton(title: "Add your first car")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        performSegue(withIdentifier: "newCarSegue", sender: nil)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -20
    }
}

// MARK: Observers

extension CarsController: ListObserver, ListObjectObserver {
    func listMonitorWillChange(_ monitor: ListMonitor<Car>) {
        carsTable.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Car>) {
        carsTable.endUpdates()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Car>) {
        carsTable.reloadData()
    }
    
    func listMonitor(_ monitor: ListMonitor<Car>, didInsertObject object: Car, toIndexPath indexPath: IndexPath) {
        carsTable.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Car>, didMoveObject object: Car, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
        carsTable.deleteRows(at: [fromIndexPath], with: .automatic)
        carsTable.insertRows(at: [toIndexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Car>, didUpdateObject object: Car, atIndexPath indexPath: IndexPath) {
        guard object.deletedAt == nil else {
            self.carsTable.deleteRows(at: [indexPath], with: .automatic)
            
            return
        }
        
        if let cell = carsTable.cellForRow(at: indexPath) as? CarCell {
            configure(cell, with: object)
        }
    }
    
    func listMonitor(_ monitor: ListMonitor<Car>, didDeleteObject object: Car, fromIndexPath indexPath: IndexPath) {
        carsTable.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: Table View - Data Source + Delegate

extension CarsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.numberOfObjects()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        carsTable.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarCell
        
        configure(cell, with: cars[indexPath.row])
        
        return cell
    }
    
    func configure(_ cell: CarCell, with car: Car) {
        cell.nameLabel.text = car.name
        cell.typeImage.image = car.image(ofSize: .regular)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            self.showDeletionPrompt(for: indexPath.row)
        }
        
        return [delete]
    }
}
