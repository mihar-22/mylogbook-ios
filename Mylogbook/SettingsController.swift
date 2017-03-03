
import Alamofire
import UIKit

class SettingsController: UITableViewController {
    
    let network = NetworkReachabilityManager()!
    
    // MARK: Outlets
 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupProfile()
        
        stateLabel.text = UserSettings.shared.australiaState
    }
    
    // MARK: Profile
    
    func setupProfile() {
        nameLabel.text = Keychain.shared.name!
        
        emailLabel.text = Keychain.shared.email!
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLogOut(_ sender: UIButton) {
        Keychain.shared.apiToken = nil
        
        logOut()
        
        navigateToAuthScene()
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}