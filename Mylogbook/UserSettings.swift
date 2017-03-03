
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
            return get(with: isSyncPreparedKey) ?? false
        }
        
        set(isSyncPrepared) {
            set(isSyncPrepared, for: isSyncPreparedKey)
        }
    }
    
    // MARK: Last Synced At
    
    private let lastSyncedAtKey = "last_synced_at"
    
    var lastSyncedAt: Date {
        get {
            return get(with: lastSyncedAtKey)!
        }
        
        set(lastSyncedAt) {
            set(lastSyncedAt, for: lastSyncedAtKey)
        }
    }
    
    // MARK: Australia State
    
    private let australiaStateKey = "australia_state"
    
    var australiaState: String? {
        get {
            return get(with: australiaStateKey) ?? AustraliaState.victoria.rawValue
        }
        
        set(state) {
            set(state, for: australiaStateKey)
        }
    }
    
    // MARK: Odometer
    
    func getOdometer(for car: Car) -> String? {
        let key = "car_\(car.id)_odometer"
        
        return get(with: key)
    }
    
    func incrementOdometerBy(_ amount: Int, for car: Car) {
        let odometer = Int(getOdometer(for: car)!)!
        
        set(odometer: "\(odometer + amount)", for: car)
    }
    
    func set(odometer: String, for car: Car) {
        let key = "car_\(car.id)_odometer"
        
        set(odometer, for: key)
    }
    
    // MARK: Getters
    
    private func get<T>(with key: String) -> T? {
        guard let id = Keychain.shared.id else { return nil }
        
        return UserDefaults.standard.value(forKey: "\(id)_\(key)") as? T
    }
    
    // MARK: Setters
    
    private func set(_ value: Any?, for key: String) {
        guard let id = Keychain.shared.id else { return }
        
        UserDefaults.standard.set(value, forKey: "\(id)_\(key)")
    }
}
