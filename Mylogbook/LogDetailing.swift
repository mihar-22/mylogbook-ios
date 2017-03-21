
import UIKit

// MARK: Log Detail Delegate

protocol LogDetailDelegate {
    func didChange(_ condition: TripCondition, isSelected: Bool)
}

// MARK: Log Detailing

protocol LogDetailing: class {
    var delegate: LogDetailDelegate? { get set }
    
    func didSelect(rowAt indexPath: IndexPath) -> Bool
}

extension LogDetailing where Self: UITableViewController {
    func didSelect(rowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)!
        
        let isSelected = (cell.accessoryType == .none)
        
        cell.accessoryType = isSelected ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        return isSelected
    }
}

// MARK: Weather Controller

class WeatherController: UITableViewController, LogDetailing {
    let conditions = TripCondition.Weather.all
    
    var delegate: LogDetailDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition: TripCondition = .weather(conditions[indexPath.row])
        
        let isSelected = didSelect(rowAt: indexPath)
        
        delegate?.didChange(condition, isSelected: isSelected)
    }
}

// MARK: Traffic Controller

class TrafficController: UITableViewController, LogDetailing {
    let conditions = TripCondition.Traffic.all
    
    var delegate: LogDetailDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition: TripCondition = .traffic(conditions[indexPath.row])
        
        let isSelected = didSelect(rowAt: indexPath)
        
        delegate?.didChange(condition, isSelected: isSelected)
    }
}

// MARK: Road Controller

class RoadController: UITableViewController, LogDetailing {
    let conditions = TripCondition.Road.all
    
    var delegate: LogDetailDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition: TripCondition = .road(conditions[indexPath.row])
        
        let isSelected = didSelect(rowAt: indexPath)
        
        delegate?.didChange(condition, isSelected: isSelected)
    }
}
