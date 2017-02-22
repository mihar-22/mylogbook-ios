
import UIKit

class LogSummaryController: UIViewController {
    
    var trip: Trip!
    
    // MARK: Actions
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        TripStore.add(trip)
        
        saveOdometer()
        
        tabBarController!.selectedIndex = 0
        
        navigationController!.popToRootViewController(animated: true)
    }
    
    // MARK: Odometer
    
    func saveOdometer() {
        let key = "car-\(trip.car!.id)-odometer"
        
        let odometer = Int(UserDefaults.standard.string(forKey: key)!)!
        
        let distance = Int(round(trip.distance))
        
        UserDefaults.standard.set((odometer + distance), forKey: key)
    }
}
