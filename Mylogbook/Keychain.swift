
import CoreLocation
import KeychainAccess

typealias AccessKeychain = KeychainAccess.Keychain

// MARK: Keychain

class Keychain {
    static let shared: Keychain = Keychain()
    
    private var keychain: AccessKeychain = {
        let urlString = Env.MLB_API_BASE
        
        let url = URL(string: urlString)!
        
        let protocolType: ProtocolType = urlString.components(separatedBy: ":")[0] == "http" ? .http : .https
        
        return AccessKeychain(server: url, protocolType: protocolType)
    }()
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Email
    
    private let emailKey = "email"
    
    var email: String? {
        get {
            return keychain[emailKey]
        }
        
        set(email) {
            keychain[emailKey] = email
        }
    }
    
    // MARK: Name
    
    private let nameKey = "name"
    
    var name: String? {
        get {
            return get(key: nameKey)
        }
        
        set(name) {
            set(name, for: nameKey)
        }
    }
    
    // MARK: Offline Password
    
    private let offlinePasswordKey = "offline_password"
    
    var offlinePassword: String? {
        get {
            return get(key: offlinePasswordKey)
        }
        
        set(password) {
            set(password, for: offlinePasswordKey)
        }
    }
    
    // MARK: Api Token
    
    private let apiTokenKey = "api_token"
    
    var apiToken: String? {
        get {
            return get(key: apiTokenKey)
        }
        
        set(apiToken) {
            set(apiToken, for: apiTokenKey)
        }
    }
    
    // MARK: Last Route
    
    private let lastRouteKey = "last_route"
    
    var lastRoute: [CLLocation]? {
        get {
            return get(key: lastRouteKey)
        }
        
        set(locations) {
            set(locations, for: lastRouteKey)
        }
    }
    
    // MARK: Accessors
    
    private func get(key: String) -> String? {
        guard let email = Keychain.shared.email else { return nil }
        
        return keychain["\(email)_\(key)"]
    }
    
    private func get<T>(key: String) -> T? {
        guard let email = Keychain.shared.email else { return nil }
        
        guard let data = try! keychain.getData("\(email)_\(key)") else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    // MARK: Setters
    
    private func set(_ value: String?, for key: String) {
        guard let email = Keychain.shared.email else { return }
        
        keychain["\(email)_\(key)"] = value
    }
    
    private func set<T>(_ object: T, for key: String) {
        guard let email = Keychain.shared.email else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        
        try! keychain.set(data, key: "\(email)_\(key)")
    }
}
