
import UIKit

// MARK: Notification

enum Notification: String {
    case syncComplete = "com.mylogbook.syncComplete"
    
    var name: NSNotification.Name {
        return NSNotification.Name(rawValue: rawValue)
    }
}
