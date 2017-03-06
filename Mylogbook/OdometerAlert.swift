
import UIKit

class OdometerAlert: UIViewController {
    
    let validator = Validator()
    
    let formatter = ValueFormatter()
    
    var odometerText: String? {
        get {
            return odometerTextField.field.valueText
        }
        
        set(odometer) {
            odometerTextField.field.valueText = odometer
        }
    }
    
    var odometerValue: Int {
        return odometerTextField.field.value
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var odometerTextField: TextField!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupValidator()
        
        odometerTextField.field.setupValueFormatting()
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.add(odometerTextField, [.required, .numeric])
    }
}
