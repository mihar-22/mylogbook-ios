
import UIKit
import PopupDialog

class SupervisorsController: UIViewController, ResourceCollectionViewable {
    
    var collection = [Supervisor]()
    
    // MARK: Outlets
    
    @IBOutlet weak var collectionTable: UITableView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        viewDidLoadHandler()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NewSupervisorController {
            viewController.delegate = self
            
            if segue.identifier == "editSupervisorSegue" {
                if let selectedCell = sender as? SupervisorCell {
                    let indexPath = collectionTable.indexPath(for: selectedCell)!
                    
                    let supervisor = collection[indexPath.row]
                    
                    viewController.editingSupervisor = supervisor
                }
            }
        }
    }
}

// MARK: Alertable

extension SupervisorsController: Alertable {
    func showSupervisorDeletionPrompt(indexPath: IndexPath) {
        let title = "Delete Supervisor"
        
        let message = "Are you sure you want to delete this supervisor permanently?"
        
        let cancelButton = CancelButton(title: "CANCEL") { self.collectionTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") { self.deleteModel(indexPath: indexPath) }
        
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: New Supervisor Delegate

extension SupervisorsController: NewSupervisorDelegate {
    func supervisorAdded(_ supervisor: Supervisor) {
        addToTable(supervisor)
    }
    
    func supervisorUpdated(_ supervisor: Supervisor) {
        collectionTable.reloadData()
    }
}

// MARK: Table View - Data Source + Delegate

extension SupervisorsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupervisorCell", for: indexPath) as! SupervisorCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: SupervisorCell, indexPath: IndexPath) {
        let supervisor = collection[indexPath.row]
        
        cell.nameLabel.text = supervisor.fullName
        cell.licenseLabel.text = supervisor.license!
        // set avatarImage here
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            self.showSupervisorDeletionPrompt(indexPath: indexPath)
        }
        
        return [delete]
    }
}
