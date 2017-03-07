
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
    
    // MARK: Key
    
    enum Key: String {
        case id = "id"
        case email = "email"
        case name = "name"
        case birthday = "birthday"
        case apiToken = "apiToken"
    }
    
    enum DataKey: String {
        case lastRoute = "lastRoute"
    }
    
    // MARK: Getters + Setters
    
    func get(_ key: Key) -> String? {
        return keychain[key.rawValue]
    }
    
    func set(_ value: String, for key: Key) {
        keychain[key.rawValue] = value
    }
    
    func getData<T>(with key: DataKey) -> T? {
        guard let id = Keychain.shared.get(.id) else { return nil }
        
        guard let data = try! keychain.getData("\(id)_\(key.rawValue)") else { return nil }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
    }
    
    func setData<T>(_ object: T, for key: DataKey) {
        guard let id = Keychain.shared.get(.id) else { return }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: object)
        
        try! keychain.set(data, key: "\(id)_\(key.rawValue)")
    }
    
    // MARK: Clear
    
    func clear(_ key: Key) {
        keychain[key.rawValue] = nil
    }
}
