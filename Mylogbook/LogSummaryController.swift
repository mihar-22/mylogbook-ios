
import UIKit

class LogSummaryController: UIViewController {
    
    var trip: Trip!
    
    // MARK: Actions
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        TripStore.add(trip)
        
        tabBarController!.selectedIndex = 0
        
        navigationController!.popToRootViewController(animated: true)
    }
}
