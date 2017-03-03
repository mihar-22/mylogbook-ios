
import UIKit

// MARK: Australia State

enum AustraliaState: String {
    static let all = [
        newSouthWhales,
        queensland,
        southAustralia,
        tasmania,
        victoria,
        westernAustralia
    ]
    
    case newSouthWhales = "New South Whales"
    case queensland = "Queensland"
    case southAustralia = "South Australia"
    case tasmania = "Tasmania"
    case victoria = "Victoria"
    case westernAustralia = "Western Australia"
}

// Mark: Australia State Controller

class AustraliaStateController: UITableViewController {
    
    var states: [AustraliaState] = AustraliaState.all
    
    var currentState: String? {
        get {
            return UserSettings.shared.australiaState
        }
        
        set(state) {
            UserSettings.shared.australiaState = state
        }
    }
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()
    }
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousState = AustraliaState.init(rawValue: currentState!)!
        
        let previousRow = states.index(of: previousState)!
        
        let previousIndexPath = IndexPath(row: previousRow, section: 0)
        
        let previousCell = tableView.cellForRow(at: previousIndexPath)!
        
        previousCell.accessoryType = .none
        
        let selectedCell = tableView.cellForRow(at: indexPath)!
        
        selectedCell.accessoryType = .checkmark
        
        currentState = states[indexPath.row].rawValue
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StateCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: identifier) }
        
        cell!.textLabel!.text = states[indexPath.row].rawValue
        
        if states[indexPath.row].rawValue == currentState { cell!.accessoryType = .checkmark }
        
        return cell!
    }
}
