
import Alamofire
import UIKit

class SettingsController: UITableViewController {
    
    let network = NetworkReachabilityManager()!
    
    // MARK: Outlets
 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var permitReceivedTextField: UITextField!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var manualEntriesCell: UITableViewCell!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupProfile()
        
        setupPermit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stateLabel.text = Cache.shared.residingState.rawValue
    }
    
    // MARK: Profile
    
    func setupProfile() {
        nameLabel.text = Keychain.shared.get(.name)!
        
        emailLabel.text = Keychain.shared.get(.email)!
    }
    
    // MARK: Permit
    
    func setupPermit() {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        
        picker.timeZone = TimeZone(secondsFromGMT: 0)
        
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        
        picker.maximumDate = Date()
        
        picker.addTarget(self, action: #selector(didChangePermitReceivedDate(_:)), for: .valueChanged)
        
        permitReceivedTextField.inputView = picker
        
        if let receivedAt = Keychain.shared.get(.permitReceivedAt) {
            permitReceivedTextField.text = receivedAt.utc(format: .date).string(date: .long, time: .none)
            
            picker.date = receivedAt.utc(format: .date)
        }
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLogOut(_ sender: UIButton) {
        Keychain.shared.clear(.apiToken)
        
        logOut()
        
        navigateToAuthScene()
    }
    
    func didChangePermitReceivedDate(_ sender: UIDatePicker) {
        Keychain.shared.set(sender.date.utc(format: .date), for: .permitReceivedAt)
        
        permitReceivedTextField.text = sender.date.string(date: .long, time: .none)
    }
    
    // MARK: Network
    
    func logOut() {
        guard network.isReachable else { return }
        
        let route = AuthRoute.logout
        
        Session.shared.requestJSON(route) { _ in }
    }
    
    // MARK: Navigation
    
    func navigateToAuthScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateInitialViewController()!
        
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath) == manualEntriesCell {
            performSegue(withIdentifier: "showManualEntriesSegue", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
