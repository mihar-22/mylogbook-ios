
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
            return UserDefaults.standard.bool(forKey: isSyncPreparedKey)
        }
        
        set(isSyncPrepared) {
            UserDefaults.standard.set(isSyncPrepared, forKey: isSyncPreparedKey)
        }
    }
    
    // MARK: Last Synced At
    
    private let lastSyncedAtKey = "last_synced_at"
    
    var lastSyncedAt: Date {
        get {
            return UserDefaults.standard.object(forKey: lastSyncedAtKey) as! Date
        }
        
        set(lastSyncedAt) {
            UserDefaults.standard.set(lastSyncedAt, forKey: lastSyncedAtKey)
        }
    }
    
    // MARK: Odometer
    
    func getOdometer(for car: Car) -> String? {
        let key = "car_\(car.id)_odometer"
        
        return UserDefaults.standard.string(forKey: key)
    }
    
    func set(odometer: String, for car: Car) {
        let key = "car_\(car.id)_odometer"
        
        UserDefaults.standard.set(odometer, forKey: key)
    }
}
