
import Foundation

// MARK: Cache

class Cache: NSObject, NSCoding {
    static var key: String {
        let id = Keychain.shared.get(.id)!
        
        return "user_\(id)_cache"
    }
    
    private static var _shared: Cache?
    
    static var shared: Cache {
        if _shared == nil {
            if let data = UserDefaults.standard.data(forKey: key) {
                _shared = NSKeyedUnarchiver.unarchiveObject(with: data) as? Cache
            } else {
                _shared = Cache()
            }
        }
        
        return _shared!
    }
    
    var isSyncPrepared: Bool = false
    
    var lastSyncedAt: Date = Date()
    
    var residingState: AustralianState = .victoria
    
    var currentEntries: Entries { return entries[residingState]! }
    
    var statistics = Statistics()
    
    private var odometers = [Int: Int]()
    
    private var entries: [AustralianState: Entries] = {
        var settings = [AustralianState: Entries]()
        
        for state in AustralianState.all { settings[state] = Entries() }
        
        return settings
    }()
    
    // MARK: Initializers
    
    override init() { super.init() }
    
    // MARK: Reset
    
    static func reset() {
        _shared = nil
    }
    
    // MARK: Getters and Setters
    
    func getOdometer(for car: Car) -> Int? {
        return odometers[car.id]
    }
    
    func set(odometer: Int, for car: Car) {
        odometers[car.id] = odometer
    }
    
    // MARK: Save
    
     func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        
        UserDefaults.standard.set(data, forKey: Cache.key)
    }
    
    // MARK: Encoding + Decoding
    
    required init?(coder aDecoder: NSCoder) {
        isSyncPrepared = aDecoder.decodeBool(forKey: "isSyncPrepared")
        lastSyncedAt = aDecoder.decodeObject(forKey: "lastSyncedAt") as! Date
        odometers = aDecoder.decodeObject(forKey: "odometers") as! [Int: Int]
        statistics = aDecoder.decodeObject(forKey: "statistics") as! Statistics
        
        let state =  aDecoder.decodeObject(forKey: "residingState") as! String
        residingState = AustralianState(rawValue: state)!
        
        let entries = aDecoder.decodeObject(forKey: "entries")
        for (state, settings) in (entries as! [String: Entries]) {
            self.entries[AustralianState(rawValue: state)!] = settings
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isSyncPrepared, forKey: "isSyncPrepared")
        aCoder.encode(lastSyncedAt, forKey: "lastSyncedAt")
        aCoder.encode(odometers, forKey: "odometers")
        aCoder.encode(statistics, forKey: "statistics")
        aCoder.encode(residingState.rawValue, forKey: "residingState")
        aCoder.encode(encodeEntries(), forKey: "entries")
    }
    
    func encodeEntries() -> [String: Entries] {
        var encoding = [String: Entries]()
        
        for (state, settings) in entries {
            encoding[state.rawValue] = settings
        }

        return encoding
    }
}
