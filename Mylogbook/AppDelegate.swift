
import Alamofire
import Dispatch
import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window?.tintColor = Palette.tint.uiColor
        
        Appearance.apply()
        
        KeyboardManager.start()
        
        launch()
        
        return true
    }
    
    private func launch() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let hasApiToken = (Keychain.shared.get(.apiToken) != nil)

        guard hasApiToken else { return }
        
        window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarSID")
        
        authenticate()
    }
    
    private func authenticate() {
        guard NetworkReachabilityManager(host: Env.MLB_API_BASE)!.isReachable else { return }
        
        let route = AuthRoute.check
        
        Session.shared.requestJSON(route) { response in
            let isAuthenticated = (response.statusCode == 200)
            
            guard isAuthenticated else {
                Keychain.shared.clear(.apiToken)
                
                return
            }
            
            SyncManager().start()
        }
    }
}

