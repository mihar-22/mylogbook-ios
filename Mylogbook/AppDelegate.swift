
import UIKit
import CoreStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask,
                                                        true)
        print(paths[0])
        
        SyncManager().start()
        
        setupRootController()
        
        return true
    }
    
    private func setupRootController() {
        let isAuthenticated = (Keychain.shared.apiToken != nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if isAuthenticated {
            window!.rootViewController = storyboard.instantiateInitialViewController()
        } else {
            window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "AuthSID")
        }
    }
}

