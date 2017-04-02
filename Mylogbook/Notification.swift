
import UIKit

// MARK: Notification

enum Notification: String {
    case syncPreparationComplete = "com.mylogbook.syncPreparationComplete"
    
    var name: NSNotification.Name {
        return NSNotification.Name(rawValue: rawValue)
    }
}
