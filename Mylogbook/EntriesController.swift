
import UIKit

class EntriesController: UITableViewController {
    
    var residingState: AustralianState = {
        return Cache.shared.residingState
    }()
    
    var entries: Entries = {
        return Cache.shared.currentEntries
    }()
    
    // MARK: Outlets
    
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var nightTextField: UITextField!
    
    @IBOutlet weak var dayBonusTextField: UITextField!
    @IBOutlet weak var nightBonusTextField: UITextField!
    
    // MARK: View Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        setup()
    }
    
    override func viewDidLoad() {
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        save()
    }
    
    // MARK: Settings
    
    func setup() {
        let secondsPerMinute = 60
        
        if entries.day > 0 {
            dayTextField.valueText = String(entries.day / secondsPerMinute)
        }
        
        if entries.night > 0 {
            nightTextField.valueText = String(entries.night / secondsPerMinute)
        }
        
        if residingState.isBonusCreditsAvailable {
            if let minutes = entries.dayBonus, minutes > 0 {
                dayBonusTextField.valueText = String(minutes / secondsPerMinute)
            }
            
            if let minutes = entries.nightBonus, minutes > 0 {
                nightBonusTextField.valueText = String(minutes / secondsPerMinute)
            }
        }
    }
    
    func save() {
        let secondsPerMinute = 60
        
        entries.day = dayTextField.value * secondsPerMinute

        entries.night = nightTextField.value * secondsPerMinute
        
        if residingState.isBonusCreditsAvailable {
            entries.dayBonus = dayBonusTextField.value * secondsPerMinute
            
            entries.nightBonus = nightBonusTextField.value * secondsPerMinute
        }
        
        Cache.shared.save()
    }
    
    // MARK: Table View
    
    func isSectionViewable(_ section: Int) -> Bool {
        return (section == 1 && !residingState.isBonusCreditsAvailable)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSectionViewable(section) { return 0.1 }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSectionViewable(section) { return 0 }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
        
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        if isSectionViewable(section) { return 0.1 }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int) {

        if isSectionViewable(section) { view.isHidden = true }
    }
    
    override func tableView(_ tableView: UITableView,
                            willDisplayFooterView view: UIView,
                            forSection section: Int) {
        
        if  isSectionViewable(section) { view.isHidden = true }
    }
}

// MARK: Text Field Delegate

extension EntriesController: UITextFieldDelegate {
    func setupTextFields() {
        setup(dayTextField, tag: 0)

        setup(nightTextField, tag: 1)
        
        if residingState.isBonusCreditsAvailable {
            setup(dayBonusTextField, tag: 2)
            
            setup(nightBonusTextField, tag: 3)
        }
    }
    
    func setup(_ textField: UITextField, tag: Int) {
        textField.tag = tag
        textField.delegate = self
        textField.setupValueFormatting()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.value > 0 else { return }

        let tag = textField.tag
        
        guard !residingState.is(.tasmania) && !residingState.is(.westernAustralia) else {
            let otherTextField = (tag == 0) ? nightTextField : dayTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!, isBonusSection: false)
            
            return
        }
        
        if tag == 0 {
            adjustDayValue()
        } else if tag == 1 {
            adjustNightValue()
        } else {
            let otherTextField = (tag == 2) ? nightBonusTextField : dayBonusTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!, isBonusSection: true)
        }
    }
    
    func adjustDayValue() {
        let minutes = dayTextField.value
        
        let maxMinutes = residingState.loggedTimeRequired.day / (secondsPerMinute: 60)
        
        let value = min(maxMinutes, minutes)
        
        dayTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustNightValue() {
        let minutes = nightTextField.value
        
        let maxMinutes = residingState.loggedTimeRequired.night / (secondsPerMinute: 60)
        
        let value = min(maxMinutes, minutes)
        
        nightTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustValueWithTotalLimit(_ textField: UITextField, _ otherTextField: UITextField, isBonusSection: Bool) {
        let secondsPerMinute = 60
        
        let  maxTotalMinutes = isBonusSection ? residingState.totalBonusAvailable / secondsPerMinute :
                                                residingState.totalLoggedTimeRequired / secondsPerMinute
        
        let totalMinutesLeft = max(0, maxTotalMinutes - otherTextField.value)
        
        let value = min(totalMinutesLeft, textField.value)
        
        textField.valueText = String(value)
    }
}
