
import CoreLocation
import KeychainAccess

typealias AccessKeychain = KeychainAccess.Keychain

// MARK: Keychain

class Keychain {
    static let shared = Keychain()
    
    private var keychain: AccessKeychain = {
        let urlString = Env.MLB_API_BASE
        
        let url = URL(string: urlString)!
        
        let protocolType: ProtocolType = urlString.components(separatedBy: ":")[0] == "http" ? .http : .https
        
        return AccessKeychain(server: url, protocolType: protocolType)
    }()
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Id
    
    private let idKey = "id"
    
    var id: String? {
        get {
            return keychain[idKey]
        }
        
        set(id) {
            keychain[idKey] = id
        }
    }
    
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
            return keychain[nameKey]
        }
        
        set(name) {
            keychain[nameKey] = name
        }
    }
    
    // MARK: Api Token
    
    private let apiTokenKey = "api_token"
    
    var apiToken: String? {
        get {
            return keychain[apiTokenKey]
        }
        
        set(apiToken) {
            keychain[apiTokenKey] = apiToken
        }
    }
    
    // MARK: Last Route
    
    private let lastRouteKey = "last_route"
    
    var lastRoute: [CLLocation]? {
        get {
            return get(with: lastRouteKey)
        }
        
        set(locations) {
            set(locations, for: lastRouteKey)
        }
    }
    
    // MARK: Archive Data
    
    private func get<T>(with key: String) -> T? {
        guard let id = Keychain.shared.id else { return nil }
        
        guard let data = try! keychain.getData("\(id)_\(key)") else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    private func set<T>(_ object: T, for key: String) {
        guard let id = Keychain.shared.id else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        
        try! keychain.set(data, key: "\(id)_\(key)")
    }
}
