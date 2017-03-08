
import Foundation

// MARK: Settings

class Settings: NSObject, NSCoding {
    static var key: String {
        let id = Keychain.shared.get(.id)!
        
        return "user_\(id)_settings"
    }
    
    static let shared: Settings = {
        guard let data = UserDefaults.standard.data(forKey: key) else { return Settings() }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! Settings
    }()
    
    var isSyncPrepared: Bool = false
    
    var lastSyncedAt: Date = Date()
    
    var residingState: AustraliaState = .victoria
    
    var currentEntries: Entries {
        return entries[residingState]!
    }
    
    private var odometers = [Int: Int]()
    
    private var entries: [AustraliaState: Entries] = {
        var settings = [AustraliaState: Entries]()
        
        for state in AustraliaState.all { settings[state] = Entries() }
        
        return settings
    }()
    
    // MARK: Getters and Setters
    
    func getOdometer(for car: Car) -> Int {
        return odometers[car.id] ?? 0
    }
    
    func set(odometer: Int, for car: Car) {
        odometers[car.id] = odometer
    }
    
    // MARK: Save
    
     func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        
        UserDefaults.standard.set(data, forKey: Settings.key)
    }
    
    // MARK: Encoding + Decoding
    
    override init() { super.init() }
    
    required init?(coder aDecoder: NSCoder) {
        isSyncPrepared = aDecoder.decodeBool(forKey: "isSyncPrepared")
        
        lastSyncedAt = aDecoder.decodeObject(forKey: "lastSyncedAt") as! Date
        
        odometers = aDecoder.decodeObject(forKey: "odometers") as! [Int: Int]
        
        let state =  aDecoder.decodeObject(forKey: "residingState") as! String

        residingState = AustraliaState(rawValue: state)!
        
        let entries = aDecoder.decodeObject(forKey: "entries")
        
        for (state, settings) in (entries as! [String: Entries]) {
            self.entries[AustraliaState(rawValue: state)!] = settings
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isSyncPrepared, forKey: "isSyncPrepared")
        
        aCoder.encode(lastSyncedAt, forKey: "lastSyncedAt")
        
        aCoder.encode(odometers, forKey: "odometers")
        
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

// MARK: Entries

class Entries: NSObject, NSCoding {
    var day = 0
    
    var night = 0
    
    var dayBonus: Int? = nil

    var nightBonus: Int? = nil
    
    var isSaferDriversComplete: Bool? = nil
    
    var isAssessmentComplete: Bool? = nil
    
    var assessmentCompletedAt: Date? = nil
        
    // MARK: Encoding + Decoding
    
    override init() { super.init() }
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: "day")
        
        night = aDecoder.decodeInteger(forKey: "night")

        dayBonus = aDecoder.decodeObject(forKey: "dayBonus") as? Int

        nightBonus = aDecoder.decodeObject(forKey: "nightBonus") as? Int

        isSaferDriversComplete = aDecoder.decodeObject(forKey: "isSaferDriversComplete") as? Bool
        
        isAssessmentComplete = aDecoder.decodeObject(forKey: "isAssessmentComplete") as? Bool
        
        assessmentCompletedAt = aDecoder.decodeObject(forKey: "assessmentCompletedAt") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        
        aCoder.encode(night, forKey: "night")

        aCoder.encode(dayBonus, forKey: "dayBonus")

        aCoder.encode(nightBonus, forKey: "nightBonus")

        aCoder.encode(isSaferDriversComplete, forKey: "isSaferDriversComplete")
        
        aCoder.encode(isAssessmentComplete, forKey: "isAssessmentComplete")
        
        aCoder.encode(assessmentCompletedAt, forKey: "assessmentCompletedAt")
    }
}
