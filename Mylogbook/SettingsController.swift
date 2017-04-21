
import Alamofire
import MessageUI
import PopupDialog
import UIKit

class SettingsController: UITableViewController {
    
    let network = NetworkReachabilityManager()!
    
    // MARK: Outlets
 
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var permitReceivedTextField: UITextField!
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var tellFriendsCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    @IBOutlet weak var contactUsCell: UITableViewCell!
    
    @IBOutlet weak var lastSyncedAtLabel: UILabel!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupProfile()
        
        setupPermit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stateLabel.text = Cache.shared.residingState.rawValue
        
        configureLastSyncedAt()
    }
    
    // MARK: Profile
    
    func setupProfile() {
        nameLabel.text = Keychain.shared.get(.name)!
        
        emailLabel.text = Keychain.shared.get(.email)!
    }
    
    // MARK: Last Synced At
    
    func configureLastSyncedAt() {
        let date = Cache.shared.lastSyncedAt
        
        let dateStyle: DateFormatter.Style = date.isDateToday ? .none : .long
        
        let lastSyncedAt = date.local(date: dateStyle, time: .short)
        
        lastSyncedAtLabel.text = "Last synchronized: \(lastSyncedAt)"
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
            permitReceivedTextField.text = receivedAt.utc(format: .date).local(date: .long, time: .none)
            
            picker.date = receivedAt.utc(format: .date)
        }
    }
    
    // MARK: Actions
    
    @IBAction func didTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapTellFriends() {
        guard MFMailComposeViewController.canSendMail() else {
            showMailCannotSendAlert()
            
            return
        }
        
        let name = Keychain.shared.get(.name)!
        
        let mailer = MFMailComposeViewController()
        
        mailer.mailComposeDelegate = self
        mailer.setSubject("\(name) invited you to Mylogbook")
        mailer.setMessageBody("Hello!\n\n I've been using Mylogbook and thought it could help you too. It's an easy way to record your hours for your logbook and track your progress towards your P's.", isHTML: false)
        
        present(mailer, animated: true, completion: nil)
    }
    
    func didTapContactUs() {
        guard MFMailComposeViewController.canSendMail() else {
            showMailCannotSendAlert()
            
            return
        }
        
        let mailer = MFMailComposeViewController()
        
        mailer.mailComposeDelegate = self
        
        let title = "What are you contacting us about?"
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let helpAction = UIAlertAction(title: "I need some help", style: .default) { _ in
            mailer.setToRecipients(["support+help@mylb.com.au"])

            mailer.setSubject("Help")
            
            self.present(mailer, animated: true, completion: nil)
        }
        
        let feedbackAction = UIAlertAction(title: "I'd like to give some feedback", style: .default) { _ in
            mailer.setToRecipients(["support+feedback@mylb.com.au"])

            mailer.setSubject("Feedback")
            
            self.present(mailer, animated: true, completion: nil)
        }

        let bugAction = UIAlertAction(title: "I'm reporting a bug", style: .default) { _ in
            mailer.setToRecipients(["support+bug@mylb.com.au"])

            mailer.setSubject("Bug")
            
            self.present(mailer, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            actionSheet.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(helpAction)
        actionSheet.addAction(feedbackAction)
        actionSheet.addAction(bugAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func didTapLogOut() {
        logOut()
        
        Keychain.shared.clear(.apiToken)
        
        Cache.reset()
        
        Store.reset()
        
        navigateToAuthScene()
    }
    
    func didChangePermitReceivedDate(_ sender: UIDatePicker) {
        Keychain.shared.set(sender.date.utc(format: .date), for: .permitReceivedAt)
        
        permitReceivedTextField.text = sender.date.local(date: .long, time: .none)
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
        if indexPath == tableView.indexPath(for: tellFriendsCell) { didTapTellFriends() }
        
        if indexPath == tableView.indexPath(for: contactUsCell) { didTapContactUs() }
        
        if indexPath == tableView.indexPath(for: logOutCell) { didTapLogOut() }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Alerting

extension SettingsController: Alerting {
    func showMailCannotSendAlert() {
        let title = "Setup Mail"
        
        let message = "You have not setup mail on this device."
        
        let settingsButton = DefaultButton(title: "SETTINGS") {
            let url = URL(string: "App-Prefs:root=Mail")!
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton, settingsButton])
    }
}

// MARK: Mail Delegate

extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
}
