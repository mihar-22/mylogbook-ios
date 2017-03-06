
import UIKit

class ManualEntriesController: UITableViewController {
    
    let formatter = ValueFormatter()
    
    let saferDriversIndexPath = IndexPath(row: 2, section: 1)
    
    var isResidingStateQueensland: Bool {
        return Settings.shared.residingState == .queensland
    }
    
    var isResidingStateNewSouthWhales: Bool {
        return Settings.shared.residingState == .newSouthWhales
    }
    
    var isBonusCreditsAvailable: Bool {
        return isResidingStateNewSouthWhales || isResidingStateQueensland
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var nightTextField: UITextField!
    
    
    @IBOutlet weak var accreditedDayTextField: UITextField!
    @IBOutlet weak var accreditedNightTextField: UITextField!
    @IBOutlet weak var saferDriversSwitch: UISwitch!
    
    // MARK: View Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        getSettings()
    }
    
    override func viewDidLoad() {
        setupTextFields()
        
        saferDriversSwitch.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveSettings()
    }

    // MARK: Settings
    
    func getSettings() {
        let settings = Settings.shared.manualEntriesForResidingState
        
        if settings.dayMinutes > 0 {
            dayTextField.valueText = String(settings.dayMinutes)
        }
        
        if settings.nightMinutes > 0 {
            nightTextField.valueText = String(settings.nightMinutes)
        }
        
        if isBonusCreditsAvailable {
            if let minutes = settings.accreditedDayMinutes, minutes > 0 {
                accreditedDayTextField.valueText = String(minutes)
            }
            
            if let minutes = settings.accreditedNightMinutes, minutes > 0 {
                accreditedNightTextField.valueText = String(minutes)
            }
        }
        
        if isResidingStateNewSouthWhales {
            if let isOn = settings.isSaferDriversCompleted {
                saferDriversSwitch.setOn(isOn, animated: false)
            }
        }
    }
    
    func saveSettings() {
        let settings = Settings.shared.manualEntriesForResidingState

         settings.dayMinutes = dayTextField.value
        
         settings.nightMinutes = nightTextField.value
        
        if isBonusCreditsAvailable {
            settings.accreditedDayMinutes = accreditedDayTextField.value
            
            settings.accreditedNightMinutes = accreditedNightTextField.value
        }
        
        if isResidingStateNewSouthWhales {
            settings.isSaferDriversCompleted = saferDriversSwitch.isOn
        }
        
        Settings.shared.save()
    }
    
    // MARK: Table View
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !isBonusCreditsAvailable {
            return 1
        }
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        if indexPath == saferDriversIndexPath && !isResidingStateNewSouthWhales { cell.isHidden = true }
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath == saferDriversIndexPath && !isResidingStateNewSouthWhales { return 0.0 }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Text Field Delegate

extension ManualEntriesController: UITextFieldDelegate {
    func setupTextFields() {
        setup(dayTextField, tag: 0)

        setup(nightTextField, tag: 1)
        
        if isBonusCreditsAvailable {
            setup(accreditedDayTextField, tag: 2)
            
            setup(accreditedNightTextField, tag: 3)
        }
    }
    
    func setup(_ textField: UITextField, tag: Int) {
        textField.tag = tag
        textField.delegate = self
        textField.setupValueFormatting()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        
        if tag == 0 { adjustDayTextFieldValue() }
        else if tag == 1 { adjustNightTextFieldValue() }
        else { adjustAccreditedTextFieldValue(for: tag) }
    }
    
    func adjustDayTextFieldValue() {
        let minutes = dayTextField.value
       
        var maxMinutes = 0
        
        switch Settings.shared.residingState {
        case .newSouthWhales:
            maxMinutes = 6000
        case .victoria:
            maxMinutes = 6600
        case .southAustralia:
            maxMinutes = 3600
        case .queensland:
            maxMinutes = 5400
        default:
            break
        }
        
        dayTextField.valueText = String(min(maxMinutes, minutes))
    }
    
    func adjustNightTextFieldValue() {
        let minutes = nightTextField.value
        
        var maxMinutes = 0
        
        switch Settings.shared.residingState {
        case .newSouthWhales:
            maxMinutes = 1200
        case .victoria:
            maxMinutes = 600
        case .southAustralia:
            maxMinutes = 900
        case .queensland:
            maxMinutes = 600
        default:
            break
        }
        
        nightTextField.valueText = String(min(maxMinutes, minutes))
    }
    
    func adjustAccreditedTextFieldValue(for tag: Int) {
        let isDayTextField = tag == accreditedDayTextField.tag
        
        let minutes = isDayTextField ? accreditedDayTextField.value : accreditedNightTextField.value
        
        let otherMinutes = isDayTextField ? accreditedNightTextField.value : accreditedDayTextField.value
        
        let totalMinutesLeft = 600 - otherMinutes
        
        if isDayTextField {
            accreditedDayTextField.valueText = String(min(totalMinutesLeft, minutes))
        } else {
            accreditedNightTextField.valueText = String(min(totalMinutesLeft, minutes))
        }
    }
}
