
import UIKit
import PopupDialog

class SupervisorsController: UIViewController {
    
    var supervisors = [Supervisor]()
    
    // MARK: Outlets
    
    @IBOutlet weak var supervisorsTable: UITableView!
    
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupTable()
        
        getSupervisors()
    }
    
    // MARK: Networking
    
    func getSupervisors() {
        let route = SupervisorRoute.index
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Supervisor]>) in
            guard let supervisorCollection = response.data else { return }
            
            self.supervisorsTable.beginUpdates()
            
            for supervisor in supervisorCollection { self.addSupervisorToTable(supervisor) }
            
            self.supervisorsTable.endUpdates()
        }
    }
    
    func deleteSupervisor(indexPath: IndexPath) {
        let supervisor = supervisors[indexPath.row]
        
        let route = SupervisorRoute.destroy(supervisor)
        
        Session.shared.requestJSON(route) { _ in
            self.removeSupervisorFromTable(indexPath: indexPath)
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? NewSupervisorController {
            viewController.delegate = self
            
            if segue.identifier == "editSupervisorSegue" {
                if let selectedCell = sender as? SupervisorCell {
                    let indexPath = supervisorsTable.indexPath(for: selectedCell)!
                    
                    let supervisor = supervisors[indexPath.row]
                    
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
        
        let cancelButton = CancelButton(title: "CANCEL") { self.supervisorsTable.isEditing = false; }
        
        let deleteButton = DestructiveButton(title: "DELETE") { self.deleteSupervisor(indexPath: indexPath) }
        
        showAlert(title: title, message: message, buttons: [cancelButton, deleteButton])
    }
}

// MARK: New Supervisor Delegate

extension SupervisorsController: NewSupervisorDelegate {
    func supervisorAdded(_ supervisor: Supervisor) {
        addSupervisorToTable(supervisor)
    }
    
    func supervisorUpdated(_ supervisor: Supervisor) {
        supervisorsTable.reloadData()
    }
}

// MARK: Table View - Data Source + Delegate

extension SupervisorsController: UITableViewDataSource, UITableViewDelegate {
    func setupTable() {
        supervisorsTable.dataSource = self
        
        supervisorsTable.delegate = self
        
        supervisorsTable.tableFooterView = UIView()
    }
    
    func addSupervisorToTable(_ supervisor: Supervisor) {
        supervisors.append(supervisor)
        
        supervisorsTable.insertRows(at: [IndexPath(row: self.supervisors.count - 1, section: 0)], with: .automatic)
    }
    
    func removeSupervisorFromTable(indexPath: IndexPath) {
        self.supervisors.remove(at: indexPath.row)
        
        self.supervisorsTable.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supervisors.count
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
        let supervisor = supervisors[indexPath.row]
        
        cell.nameLabel.text = "\(supervisor.firstName!) \(supervisor.lastName!)"
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
