
import UIKit

class WeatherController: UITableViewController, LogDetailing {
    let keys = ["clear", "rain", "thunder"]
    
    var data = [String: Bool]()
    
    var delegate: LogDetailDelegate?
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        prepareData()
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        let key = keys[indexPath.row]
        
        let didOccur = data[key]!
        
        if didOccur { cell.accessoryType = .checkmark }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(rowAt: indexPath)
    }
}
