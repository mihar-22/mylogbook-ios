
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
        guard !residingState.isBonusCreditsAvailable else {
            setupWithBonus()
            
            return
        }
        
        setup()
    }
    
    override func viewDidLoad() {
        setupTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard !residingState.isBonusCreditsAvailable else {
            saveWithBonus()
            
            return
        }
        
        save()
    }
    
    // MARK: Settings
    
    func setup() {
        let dayValue = entries.day.convert(from: .second, to: .minute)
        let nightValue = entries.night.convert(from: .second, to: .minute)

        if dayValue > 0 { dayTextField.valueText = String(dayValue) }
        if nightValue > 0 { nightTextField.valueText = String(nightValue) }
    }
    
    func setupWithBonus() {
        let dayValue = entries.day.convert(from: .second, to: .minute)
        let nightValue = entries.night.convert(from: .second, to: .minute)
        let dayBonusValue = (entries.dayBonus ?? 0).convert(from: .second, to: .minute) / residingState.bonusMultiplier
        let nightBonusValue = (entries.nightBonus ?? 0).convert(from: .second, to: .minute) / residingState.bonusMultiplier
        
        let dayValueAdjusted = max(dayValue, dayBonusValue) - min(dayValue, dayBonusValue)
        if dayValueAdjusted > 0 { dayTextField.valueText = String(dayValueAdjusted) }
        
        let nightValueAdjusted = max(nightValue, nightBonusValue) - min(nightValue, nightBonusValue)
        if nightValueAdjusted > 0 { nightTextField.valueText = String(nightValueAdjusted) }
        
        if dayBonusValue > 0 { dayBonusTextField.valueText = String(dayBonusValue) }
        if nightBonusValue > 0 { nightBonusTextField.valueText = String(nightBonusValue) }
    }
    
    func save() {
        let dayValue = dayTextField.value.convert(from: .minute, to: .second)
        let nightValue = nightTextField.value.convert(from: .minute, to: .second)
        
        entries.day = dayValue
        entries.night = nightValue
        
        Cache.shared.save()
    }
    
    func saveWithBonus() {
        let dayValue = dayTextField.value.convert(from: .minute, to: .second)
        let nightValue = nightTextField.value.convert(from: .minute, to: .second)
        let dayBonusValue = dayBonusTextField.value.convert(from: .minute, to: .second)
        let nightBonusValue = nightBonusTextField.value.convert(from: .minute, to: .second)
        
        entries.day = dayValue + dayBonusValue
        entries.night = nightValue + nightBonusValue
        entries.dayBonus = dayBonusValue * residingState.bonusMultiplier
        entries.nightBonus = nightBonusValue * residingState.bonusMultiplier
        
        Cache.shared.statistics.refresh()
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
        setup(dayTextField)

        setup(nightTextField)
        
        if residingState.isBonusCreditsAvailable {
            setup(dayBonusTextField)
            
            setup(nightBonusTextField)
        }
    }
    
    func setup(_ textField: UITextField) {
        textField.delegate = self
        textField.setupValueFormatting()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.value > 0 else { return }
        
        let tag = textField.tag
        
        guard !residingState.is(.tasmania) && !residingState.is(.westernAustralia) else {
            let otherTextField = (tag == dayTextField.tag) ? nightTextField : dayTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!, isBonusSection: false)
            
            return
        }
        
        if tag == dayTextField.tag {
            adjustDayValue()
        } else if tag == nightTextField.tag {
            adjustNightValue()
        } else {
            let otherTextField = (tag == dayBonusTextField.tag) ? nightBonusTextField : dayBonusTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!, isBonusSection: true)
        }
    }
    
    func adjustDayValue() {
        let minutes = dayTextField.value
        
        let maxMinutes = residingState.loggedTimeRequired.day.convert(from: .second, to: .minute)
        
        let value = min(maxMinutes, minutes)
        
        dayTextField.valueText = String(value)
    }
    
    func adjustNightValue() {
        let minutes = nightTextField.value
        
        let maxMinutes = residingState.loggedTimeRequired.night.convert(from: .second, to: .minute)
        
        let value = min(maxMinutes, minutes)
        
        nightTextField.valueText = String(value)
    }
    
    func adjustValueWithTotalLimit(_ textField: UITextField, _ otherTextField: UITextField, isBonusSection: Bool) {
        let maxTotalMinutes = isBonusSection ? residingState.timeBonusIsAvailable.convert(from: .second, to: .minute):
                                               residingState.totalLoggedTimeRequired.convert(from: .second, to: .minute)
        
        let totalMinutesLeft = max(0, maxTotalMinutes - otherTextField.value)
        
        let value = min(totalMinutesLeft, textField.value)
        
        textField.valueText = String(value)
    }
}
