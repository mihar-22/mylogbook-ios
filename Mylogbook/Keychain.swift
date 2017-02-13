
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
    
    // MARK: API Token
    
    private let apiTokenKey = "api_token"
    
    var apiToken: String? {
        get {
            return get(withKey: apiTokenKey)
        }
        
        set(apiToken) {
            set(value: apiToken, forKey: apiTokenKey)
        }
    }

    // MARK: Name

    private let nameKey = "name"
    
    var name: String? {
        get {
            return get(withKey: nameKey)
        }
        
        set(name) {
            set(value: name, forKey: nameKey)
        }
    }

    // MARK: Email

    private let emailKey = "email"
    
    var email: String? {
        get {
            return get(withKey: emailKey)
        }
        
        set(email) {
            set(value: email, forKey: emailKey)
        }
    }

    // MARK: Password
    
    private let passwordKey = "password"
    
    var password: String? {
        get {
            return get(withKey: passwordKey)
        }
        
        set(password) {
            set(value: password, forKey: passwordKey)
        }
    }
    
    // MARK: Mutators
    
    private func get(withKey key: String) -> String? {
        return keychain[key]
    }
    
    private func set(value: String?, forKey key: String) {
        keychain[key] = value
    }
}
