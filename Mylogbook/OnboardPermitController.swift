
import UIKit

class OnboardPermitController: UIViewController {
 
    var receivedDate: String?
    
    // MARK: Outlets
    
    @IBOutlet weak var receivedDateTextField: TextField!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.setHidesBackButton(true, animated: false)

        navigationController?.navigationBar.restyle(.transparent)
    }
    
    // MARK: Date Picker
    
    func setupDatePicker() {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        
        picker.maximumDate = Date()
        
        picker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        
        receivedDateTextField.inputView = picker
    }
    
    // MARK: Actions
    
    func didChangeDate(_ sender: UIDatePicker) {
        receivedDate = sender.date.utc(format: .date)
        
        receivedDateTextField.text = sender.date.local(date: .long, time: .none)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let receivedAt = receivedDate ?? Date().utc(format: .date)
        
        Keychain.shared.set(receivedAt, for: .permitReceivedAt)
    }
}
