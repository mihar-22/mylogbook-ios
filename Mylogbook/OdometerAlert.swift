
import UIKit

class OdometerAlert: UIViewController {
    
    let validator = Validator()
    
    let formatter = NumberFormatter()
    
    var odometer: String? {
        get {
            return odometerTextField.text?.replacingOccurrences(of: ",", with: "")
        }
        
        set(odometer) {
            guard (odometer != nil) && !odometer!.isEmpty else { return }
            
            guard Validation.numeric.validate(odometer!) else { return }
            
            let raw = odometer!.replacingOccurrences(of: ",", with: "")
            
            let number = formatter.number(from: raw)!
            
            odometerTextField.text = formatter.string(from: number)
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var odometerTextField: TextField!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupValidator()
        
        setupFormatter()
        
        odometerTextField.field.addTarget(self,
                                          action: #selector(editingChangedHandler(_:)),
                                          for: .editingChanged)
    }
    
    // MARK: Validator
    
    func setupValidator() {
        validator.add(odometerTextField, [.required, .numeric])
    }
    
    // MARK: Formatter
    
    func setupFormatter() {
        formatter.numberStyle = .decimal
        
        formatter.maximumFractionDigits = 0
    }
    
    // MARK: Handlers
    
    func editingChangedHandler(_ sender: UITextField) { odometer = sender.text }
}
