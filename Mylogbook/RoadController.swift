
import UIKit

class RoadController: UITableViewController, LogDetailing {
    let keys = [
        "localStreet",
        "mainRoad",
        "innerCity",
        "freeway",
        "ruralHighway",
        "gravel"
    ]
    
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
