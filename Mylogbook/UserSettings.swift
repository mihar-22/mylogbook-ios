
import Foundation

// MARK: User Settings

class UserSettings {
    static let shared: UserSettings = UserSettings()
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Is Sync Prepared
    
    private let isSyncPreparedKey = "is_sync_prepared"
    
    var isSyncPrepared: Bool {
        get {
            return get(key: isSyncPreparedKey) as? Bool ?? false
        }
        
        set(isSyncPrepared) {
            set(isSyncPrepared, for: isSyncPreparedKey)
        }
    }
    
    // MARK: Last Synced At
    
    private let lastSyncedAtKey = "last_synced_at"
    
    var lastSyncedAt: Date {
        get {
            return get(key: lastSyncedAtKey) as! Date
        }
        
        set(lastSyncedAt) {
            set(lastSyncedAt, for: lastSyncedAtKey)
        }
    }
    
    // MARK: Odometer
    
    func getOdometer(for car: Car) -> String? {
        let key = "car_\(car.id)_odometer"
        
        return get(key: key) as? String
    }
    
    func set(odometer: String, for car: Car) {
        let key = "car_\(car.id)_odometer"
        
        set(odometer, for: key)
    }
    
    // MARK: Getters
    
    private func get(key: String) -> Any? {
        guard let id = Keychain.shared.id else { return nil }
        
        return UserDefaults.standard.value(forKey: "\(id)_\(key)")
    }
    
    // MARK: Setters
    
    private func set(_ value: Any?, for key: String) {
        guard let id = Keychain.shared.id else { return }
        
        UserDefaults.standard.set(value, forKey: "\(id)_\(key)")
    }
}
