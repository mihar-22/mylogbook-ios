
import UIKit

// MARK: Log Detail Delegate

protocol LogDetailDelegate {
    func didChange(key: String, didOccur: Bool)
}

// MARK: Log Detailing

protocol LogDetailing: class {
    var keys: [String] { get }
    
    var data: [String: Bool] { get set }
    
    var delegate: LogDetailDelegate? { get set }
    
    func prepareData()
    
    func didSelect(rowAt indexPath: IndexPath)
    
    func toggleCheckMark(for indexPath: IndexPath)
}

extension LogDetailing where Self: UITableViewController {
    func prepareData() {
        for key in keys {
            if data[key] == nil { data[key] = false }
        }
    }
    
    func didSelect(rowAt indexPath: IndexPath) {
        toggleCheckMark(for: indexPath)
        
        let key = keys[indexPath.row]
        
        data[key] = !data[key]!
        
        delegate?.didChange(key: key, didOccur: data[key]!)
    }
    
    func toggleCheckMark(for indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let key = keys[indexPath.row]
        
        let isChecked = !data[key]!
        
        cell?.accessoryType = isChecked ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
