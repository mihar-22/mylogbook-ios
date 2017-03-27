
import UIKit
import CoreStore
import PopupDialog

class SupervisorsController: UIViewController {
    
    var supervisors = Store.shared.stack.monitorList(From<Supervisor>(),
                                                     Where("deletedAt = nil"),
                                                     OrderBy(.ascending("name")))
    
    // MARK: Outlets
    
    @IBOutlet weak var supervisorsTable: UITableView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        supervisors.addObserver(self)
    }
    
    deinit {
        supervisors.removeObserver(self)
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SupervisorController {
            if segue.identifier == "editSupervisorSegue" {
                if let selectedCell = sender as? SupervisorCell {
                    let indexPath = supervisorsTable.indexPath(for: selectedCell)!
                    
                    let supervisor = supervisors[indexPath.row]
                    
                    viewController.supervisor = supervisor
                }
            }
        }
    }
}

// MARK: Alerting

extension SupervisorsController: Alerting {
    func showDeletionPrompt(for index: Int) {
        let title = "Delete Supervisor"
        
        let message = "Are you sure you want to delete this supervisor permanently?"
        
        let cancelButton = CancelButton(title: "CANCEL") { self.supervisorsTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") {
            let supervisor = self.supervisors[index]
            
            SupervisorStore.delete(supervisor)
        }
        
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: Observers

extension SupervisorsController: ListObserver, ListObjectObserver {
    func listMonitorWillChange(_ monitor: ListMonitor<Supervisor>) {
        supervisorsTable.beginUpdates()
    }
    
    func listMonitorDidChange(_ monitor: ListMonitor<Supervisor>) {
        supervisorsTable.endUpdates()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Supervisor>) {
        supervisorsTable.reloadData()
    }
    
    func listMonitor(_ monitor: ListMonitor<Supervisor>, didInsertObject object: Supervisor, toIndexPath indexPath: IndexPath) {
        supervisorsTable.insertRows(at: [indexPath], with: .automatic)
    }
    
    func listMonitor(_ monitor: ListMonitor<Supervisor>, didUpdateObject object: Supervisor, atIndexPath indexPath: IndexPath) {
        guard object.deletedAt == nil else {
            self.supervisorsTable.deleteRows(at: [indexPath], with: .automatic)
            
            return
        }
        
        let cell = supervisorsTable.cellForRow(at: indexPath) as! SupervisorCell
        
        configure(cell, with: object)
    }
    
    func listMonitor(_ monitor: ListMonitor<Supervisor>, didDeleteObject object: Supervisor, fromIndexPath indexPath: IndexPath) {
        supervisorsTable.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: Table View - Data Source + Delegate

extension SupervisorsController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supervisors.numberOfObjects()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SupervisorCell", for: indexPath) as! SupervisorCell
        
        configure(cell, with: supervisors[indexPath.row])
        
        return cell
    }
    
    func configure(_ cell: SupervisorCell, with supervisor: Supervisor) {
        cell.nameLabel.text = supervisor.name
        // set gender image here
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            self.showDeletionPrompt(for: indexPath.row)
        }
        
        return [delete]
    }
}
