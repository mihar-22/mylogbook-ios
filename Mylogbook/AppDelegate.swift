
import Alamofire
import CoreStore
import Dispatch
import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Appearance.apply()
        
        KeyboardManager.start()
        
        launch()
        
        return true
    }
    
    private func launch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let hasApiToken = (Keychain.shared.apiToken != nil)

        guard hasApiToken else {
            window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "AuthSID")
            
            return
        }
        
        window!.rootViewController = storyboard.instantiateInitialViewController()
        
        authenticate()
    }
    
    private func authenticate() {
        guard NetworkReachabilityManager(host: Env.MLB_API_BASE)!.isReachable else { return }
        
        let route = AuthRoute.check
        
        Session.shared.requestJSON(route) { response in
            let isAuthenticated = (response.statusCode == 200)
            
            guard isAuthenticated else {
                Keychain.shared.apiToken = nil
                
                return
            }
            
            SyncManager().start()
        }
    }
}

