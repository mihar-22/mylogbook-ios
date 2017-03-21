
import CoreLocation
import PopupDialog
import UIKit

class LogDetailsController: UIViewController {
    
    var trip: Trip!
    
    var locations: [CLLocation]!
    
    // MARK: Outlets
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    // MARK: Actions
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        showCancelAlert()
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedWeatherTableSegue" {
            let controller = segue.destination as! WeatherController
            
            controller.delegate = self
        }
        
        if segue.identifier == "embedTrafficTableSegue" {
            let controller = segue.destination as! TrafficController
            
            controller.delegate = self
        }
        
        if segue.identifier == "embedRoadTableSegue" {
            let controller = segue.destination as! RoadController
            
            controller.delegate = self
        }
        
        if segue.identifier == "logSummarySegue" {
            if let controller = segue.destination as? LogSummaryController {
                controller.trip = trip
                
                controller.locations = locations
            }
        }
    }
    
    // MARK: Validate
    
    func validate() {
        let isValid = !trip.weather.isEmpty &&
                      !trip.traffic.isEmpty &&
                      !trip.roads.characters.isEmpty

        nextButton.isEnabled = isValid
    }
}

// MARK: Log Detail Delegate

extension LogDetailsController: LogDetailDelegate {
    func didChange(_ condition: TripCondition, isSelected: Bool) {
        trip.set(isSelected, for: condition)
        
        validate()
    }
}

// MARK: Alerting

extension LogDetailsController: Alerting {
    func showCancelAlert() {
        let title = "Cancel Recording"
        
        let message = "Are you sure? Progress will be lost."
        
        let noButton = CancelButton(title: "NO", action: nil)
        
        let yesButton = DefaultButton(title: "YES") {
            self.navigationController!.popToRootViewController(animated: true)
        }
        
        showAlert(title: title, message: message, buttons: [noButton, yesButton])
    }
}
