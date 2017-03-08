
import UIKit

class ManualEntriesController: UITableViewController {
    
    var assessmentDate: Date?
    
    var isBonusCreditsAvailable: Bool {
        return isResidingState(.newSouthWhales) || isResidingState(.queensland)
    }
    
    var isTestsAvailable: Bool {
        return isResidingState(.tasmania) || isResidingState(.westernAustralia)
    }
    
    func isResidingState(_ state: AustraliaState) -> Bool {
        return Settings.shared.residingState == state
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var nightTextField: UITextField!
    
    
    @IBOutlet weak var accreditedDayTextField: UITextField!
    @IBOutlet weak var accreditedNightTextField: UITextField!
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
        
        if isResidingState(.newSouthWhales) {
            if let isOn = settings.isSaferDriversComplete {
                saferDriversSwitch.setOn(isOn, animated: false)
            }
        }
        
        if isTestsAvailable {
            if let isOn = settings.isAssessmentComplete {
                assessmentSwitch.setOn(isOn, animated: false)
                
                assessmentDateTextField.isEnabled = isOn
                
                if isOn {
                    let date = settings.assessmentCompletedAt?.string(date: .long, time: .none)
                    
                    assessmentDateTextField.text = date
                }
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
        
        if isResidingState(.newSouthWhales) {
            settings.isSaferDriversComplete = saferDriversSwitch.isOn
        }
        
        if isTestsAvailable {
            let isOn = assessmentSwitch.isOn
            
            settings.isAssessmentComplete = isOn
            
            settings.assessmentCompletedAt = isOn ? assessmentDate ?? Date() : nil
        }
        
        Settings.shared.save()
    }
    
    // MARK: Switch
    
    func setupSwitches() {
        setupSaferDriverSwitch()
        
        setupAssessmentSwitch()
    }
    
    func setupSaferDriverSwitch() {
        guard isResidingState(.newSouthWhales) else { return }
        
        let scale: CGFloat = 0.8
        
        saferDriversSwitch.transform = CGAffineTransform.init(scaleX: scale, y: scale)
    }
    
    func setupAssessmentSwitch() {
        guard isTestsAvailable else { return }

        let scale: CGFloat = 0.8
        
        assessmentSwitch.transform = CGAffineTransform.init(scaleX: scale, y: scale)
        
        assessmentSwitch.addTarget(self, action: #selector(didChangeAssessment(_:)), for: .valueChanged)
    }
    
    // MARK: Test Section
    
    func setupTestSection() {
        guard isTestsAvailable else { return }
        
        if isResidingState(.tasmania) { assessmentLabel.text = "L2 Driving Assessment" }
        
        if isResidingState(.westernAustralia) { assessmentLabel.text = "Practical Driving Assessment" }
    }
    
    // MARK: Table View
    
    func isCellViewable(at indexPath: IndexPath) -> Bool {
        return (indexPath == IndexPath(row: 2, section: 1) && !isResidingState(.newSouthWhales))
    }
    
    func isSectionViewable(_ section: Int) -> Bool {
        return (section == 1 && !isBonusCreditsAvailable) ||
               (section == 2 && !isTestsAvailable )
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

extension ManualEntriesController: UITextFieldDelegate {
    func setupTextFields() {
        setup(dayTextField, tag: 0)

        setup(nightTextField, tag: 1)
        
        if isBonusCreditsAvailable {
            setup(accreditedDayTextField, tag: 2)
            
            setup(accreditedNightTextField, tag: 3)
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
        
        guard !isTestsAvailable else {
            let otherTextField = (tag == 0) ? nightTextField : dayTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!)
            
            return
        }
        
        if tag == 0 {
            adjustDayValue()
        } else if tag == 1 {
            adjustNightValue()
        } else {
            let otherTextField = (tag == 2) ? accreditedNightTextField : accreditedDayTextField
            
            adjustValueWithTotalLimit(textField, otherTextField!)
        }
    }
    
    func adjustDayValue() {
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
        
        let value = min(maxMinutes, minutes)
        
        dayTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustNightValue() {
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
        
        let value = min(maxMinutes, minutes)
        
        nightTextField.valueText = (value > 0) ? String(value) : nil
    }
    
    func adjustValueWithTotalLimit(_ textField: UITextField, _ otherTextField: UITextField) {
        var totalMinutes = 0
        
        switch Settings.shared.residingState {
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
