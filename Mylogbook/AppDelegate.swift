
import UIKit
import CoreStore
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Appearance.apply()
        
        setupRootController()
        
        KeyboardManager.start()
        
        SyncManager().start()
        
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

