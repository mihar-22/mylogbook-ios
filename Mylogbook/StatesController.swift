
import UIKit

// MARK: Australian State

enum AustralianState: String {
    case newSouthWhales = "New South Whales"
    case queensland = "Queensland"
    case southAustralia = "South Australia"
    case tasmania = "Tasmania"
    case victoria = "Victoria"
    case westernAustralia = "Western Australia"
    
    static let all = [
        newSouthWhales,
        queensland,
        southAustralia,
        tasmania,
        victoria,
        westernAustralia
    ]
    
    var isBonusCreditsAvailable: Bool {
        return self == .newSouthWhales || self == .queensland
    }
    
    var isTestsAvailable: Bool {
        return self == .tasmania || self == .westernAustralia
    }
    
    func `is`(_ state: AustralianState) -> Bool {
        return self == state
    }
}

// MARK: States Controller

class StatesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var states: [AustralianState] = AustralianState.all
    
    var currentState: AustralianState {
        get {
            return Cache.shared.residingState
        }
        
        set(state) {
            Cache.shared.residingState = state
        }
    }
    
    // MARK: View Lifecycles
    
    override func viewWillDisappear(_ animated: Bool) {
        Cache.shared.save()
    }
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousRow = states.index(of: currentState)!
        
        let previousIndexPath = IndexPath(row: previousRow, section: 0)
        
        let previousCell = tableView.cellForRow(at: previousIndexPath)!
        
        previousCell.accessoryType = .none
        
        let selectedCell = tableView.cellForRow(at: indexPath)!
        
        selectedCell.accessoryType = .checkmark
        
        currentState = states[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "StateCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if (cell == nil) { cell = UITableViewCell(style: .default, reuseIdentifier: identifier) }
        
        cell!.textLabel!.text = states[indexPath.row].rawValue
        
        if states[indexPath.row] == currentState { cell!.accessoryType = .checkmark }
        
        return cell!
    }
}
