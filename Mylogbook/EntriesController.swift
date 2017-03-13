
import UIKit

class EntriesController: UITableViewController {
    
    var assessmentDate: Date?
    
    var residingState: AustralianState {
        return Cache.shared.residingState
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var nightTextField: UITextField!
    
    @IBOutlet weak var dayBonusTextField: UITextField!
    @IBOutlet weak var nightBonusTextField: UITextField!
    @IBOutlet weak var saferDriversSwitch: UISwitch!
    
    @IBOutlet weak var assessmentLabel: UILabel!
    @IBOutlet weak var assessmentSwitch: UISwitch!
    @IBOutlet weak var assessmentDateTextField: UITextField!
    
    // MARK: View Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        getSettings()
    }
    
    override func viewDidLoad() {
        setupTextFields()
        
        setupTestSection()
        
        setupSwitches()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveSettings()
    }
    
    // MARK: Actions
    
    func didChangeAssessment(_ sender: UISwitch) {
        assessmentDateTextField.isEnabled = sender.isOn
    }
    
    func didChangeAssessmentDate(_ sender: UIDatePicker) {
        assessmentDate = sender.date.string(format: .date).date(format: .date)
        
        assessmentDateTextField.text = sender.date.string(date: .long, time: .none)
    }
    
    // MARK: Settings
    
    func getSettings() {
        let entries = Cache.shared.currentEntries
        
        let minutesPerSecond = 60
        
        if entries.day > 0 {
            dayTextField.valueText = String(entries.day / minutesPerSecond)
        }
        
        if entries.night > 0 {
            nightTextField.valueText = String(entries.night / minutesPerSecond)
        }
        
        if residingState.isBonusCreditsAvailable {
            if let minutes = entries.dayBonus, minutes > 0 {
                dayBonusTextField.valueText = String(minutes / minutesPerSecond)
            }
            
            if let minutes = entries.nightBonus, minutes > 0 {
                nightBonusTextField.valueText = String(minutes / minutesPerSecond)
            }
        }
        
        if residingState.is(.newSouthWhales) {
            if let isOn = entries.isSaferDriversComplete {
                saferDriversSwitch.setOn(isOn, animated: false)
            }
        }
        
        if residingState.isTestsAvailable {
            if let isOn = entries.isAssessmentComplete {
                assessmentSwitch.setOn(isOn, animated: false)
                
                assessmentDateTextField.isEnabled = isOn
                
                if isOn {
                    let date = entries.assessmentCompletedAt?.string(date: .long, time: .none)
                    
                    assessmentDateTextField.text = date
                }
            }
        }
    }
    
    func saveSettings() {
        let entries = Cache.shared.currentEntries

        let secondsPerMinute = 60
        
        entries.day = dayTextField.value * secondsPerMinute

        entries.night = nightTextField.value * secondsPerMinute
        
        if residingState.isBonusCreditsAvailable {
            entries.dayBonus = dayBonusTextField.value * secondsPerMinute
            
            entries.nightBonus = nightBonusTextField.value * secondsPerMinute
        }
        
        if residingState.is(.newSouthWhales) {
            entries.isSaferDriversComplete = saferDriversSwitch.isOn
        }
        
        if residingState.isTestsAvailable {
            let isOn = assessmentSwitch.isOn
            
            entries.isAssessmentComplete = isOn
            
            entries.assessmentCompletedAt = isOn ? assessmentDate ?? Date() : nil
        }
        
        Cache.shared.save()
    }
    
    // MARK: Switch
    
    func setupSwitches() {
        setupSaferDriverSwitch()
        
        setupAssessmentSwitch()
    }
    
    func setupSaferDriverSwitch() {
        guard residingState.is(.newSouthWhales) else { return }
        
        let scale: CGFloat = 0.8
        
        saferDriversSwitch.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    }
    
    func setupAssessmentSwitch() {
        guard residingState.isTestsAvailable else { return }

        let scale: CGFloat = 0.8
        
        assessmentSwitch.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        assessmentSwitch.addTarget(self, action: #selector(didChangeAssessment(_:)), for: .valueChanged)
    }
    
    // MARK: Test Section
    
    func setupTestSection() {
        guard residingState.isTestsAvailable else { return }
        
        if residingState.is(.tasmania) { assessmentLabel.text = "L2 Driving Assessment" }
        
        if residingState.is(.westernAustralia) { assessmentLabel.text = "Practical Driving Assessment" }
    }
    
    // MARK: Table View
    
    func isCellViewable(at indexPath: IndexPath) -> Bool {
        return (indexPath == IndexPath(row: 2, section: 1) && !residingState.is(.newSouthWhales))
    }
    
    func isSectionViewable(_ section: Int) -> Bool {
        return (section == 1 && !residingState.isBonusCreditsAvailable) ||
               (section == 2 && !residingState.isTestsAvailable )
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
    
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        
        if isCellViewable(at: indexPath) { cell.isHidden = true }
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isCellViewable(at: indexPath) { return 0.0 }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        setupAssessmentDatePicker()
    }
    
    func setupAssessmentDatePicker() {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        
        picker.maximumDate = Date()
        
        picker.addTarget(self, action: #selector(didChangeAssessmentDate(_:)), for: .valueChanged)
        
        assessmentDateTextField.inputView = picker
    }
    
    func setup(_ textField: UITextField, tag: Int) {
        textField.tag = tag
        textField.delegate = self
        textField.setupValueFormatting()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        
        guard !residingState.isTestsAvailable else {
            let otherTextField = (tag == 0) ? nightTextField : dayTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!)
            
            return
        }
        
        if tag == 0 {
            adjustDayValue()
        } else if tag == 1 {
            adjustNightValue()
        } else {
            let otherTextField = (tag == 2) ? nightBonusTextField : dayBonusTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!)
        }
    }
    
    func adjustDayValue() {
        let minutes = dayTextField.value
       
        var maxMinutes = 0
        
        switch residingState {
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
        
        let value = min(maxMinutes, minutes)
        
        dayTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustNightValue() {
        let minutes = nightTextField.value
        
        var maxMinutes = 0
        
        switch residingState {
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
        
        let value = min(maxMinutes, minutes)
        
        nightTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustValueWithTotalLimit(_ textField: UITextField, _ otherTextField: UITextField) {
        var totalMinutes = 0
        
        switch residingState {
        case .queensland, .newSouthWhales:
            totalMinutes = 600
        case .tasmania:
            totalMinutes = 4800
        case .westernAustralia:
            totalMinutes = 3000
        default:
            break
        }
        
        let totalMinutesLeft = max(0, totalMinutes - otherTextField.value)
        
        let value = min(totalMinutesLeft, textField.value)
        
        textField.valueText = (value > 0) ? String(value) : nil
    }
}
