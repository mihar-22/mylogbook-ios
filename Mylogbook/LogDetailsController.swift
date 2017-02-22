
import PopupDialog
import UIKit

class LogDetailsController: UIViewController {
    
    var trip: Trip!
    
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
            
            controller.data["clear"] = trip.clear
            controller.data["rain"] = trip.rain
            controller.data["thunder"] = trip.thunder
            
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
            }
        }
    }
    
    // MARK: Validate
    
    func validate() {
        let json = trip.toJSON()
        
        let weather = json["weather"] as! [String: Bool]
        
        let traffic = json["traffic"] as! [String: Bool]
        
        let roads = json["roads"] as! [String: Bool]
        
        let isValid = weather.values.contains(true) &&
                      traffic.values.contains(true) &&
                      roads.values.contains(true)

        nextButton.isEnabled = isValid
    }
}

// MARK: Log Detail Delegate

extension LogDetailsController: LogDetailDelegate {
    func didChange(key: String, didOccur: Bool) {
        trip.setValue(didOccur, forKey: key)
        
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
