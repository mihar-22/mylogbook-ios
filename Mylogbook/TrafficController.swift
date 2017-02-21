
import UIKit

class TrafficController: UITableViewController, LogDetailing {
    let keys = ["light", "moderate", "heavy"]
    
    var data = [String: Bool]()
    
    var delegate: LogDetailDelegate?
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        prepareData()
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(rowAt: indexPath)        
    }
}
