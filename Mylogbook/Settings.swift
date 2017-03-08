
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
    
    var manualEntriesForResidingState: ManualEntries {
        return manualEntries[residingState]!
    }
    
    private var odometers = [Int: Int]()
    
    private var manualEntries: [AustraliaState: ManualEntries] = {
        var settings = [AustraliaState: ManualEntries]()
        
        for state in AustraliaState.all { settings[state] = ManualEntries() }
        
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
        
        let manualEntries = aDecoder.decodeObject(forKey: "manualEntries")
        
        for (state, settings) in (manualEntries as! [String: ManualEntries]) {
            self.manualEntries[AustraliaState(rawValue: state)!] = settings
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(isSyncPrepared, forKey: "isSyncPrepared")
        
        aCoder.encode(lastSyncedAt, forKey: "lastSyncedAt")
        
        aCoder.encode(odometers, forKey: "odometers")
        
        aCoder.encode(residingState.rawValue, forKey: "residingState")
        
        aCoder.encode(encodeManualEntries(), forKey: "manualEntries")
    }
    
    func encodeManualEntries() -> [String: ManualEntries] {
        var encoding = [String: ManualEntries]()
        
        for (state, settings) in manualEntries {
            encoding[state.rawValue] = settings
        }

        return encoding
    }
}

// MARK: Manual Entries

class ManualEntries: NSObject, NSCoding {
    var dayMinutes = 0
    
    var nightMinutes = 0
    
    var accreditedDayMinutes: Int? = nil

    var accreditedNightMinutes: Int? = nil
    
    var isSaferDriversComplete: Bool? = nil
    
    var isAssessmentComplete: Bool? = nil
    
    var assessmentCompletedAt: Date? = nil
        
    // MARK: Encoding + Decoding
    
    override init() { super.init() }
    
    required init?(coder aDecoder: NSCoder) {
        dayMinutes = aDecoder.decodeInteger(forKey: "dayMinutes")
        
        nightMinutes = aDecoder.decodeInteger(forKey: "nightMinutes")

        accreditedDayMinutes = aDecoder.decodeObject(forKey: "accreditedDayMinutes") as? Int

        accreditedNightMinutes = aDecoder.decodeObject(forKey: "accreditedNightMinutes") as? Int

        isSaferDriversComplete = aDecoder.decodeObject(forKey: "isSaferDriversComplete") as? Bool
        
        isAssessmentComplete = aDecoder.decodeObject(forKey: "isAssessmentComplete") as? Bool
        
        assessmentCompletedAt = aDecoder.decodeObject(forKey: "assessmentCompletedAt") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dayMinutes, forKey: "dayMinutes")
        
        aCoder.encode(nightMinutes, forKey: "nightMinutes")

        aCoder.encode(accreditedDayMinutes, forKey: "accreditedDayMinutes")

        aCoder.encode(accreditedNightMinutes, forKey: "accreditedNightMinutes")

        aCoder.encode(isSaferDriversComplete, forKey: "isSaferDriversComplete")
        
        aCoder.encode(isAssessmentComplete, forKey: "isAssessmentComplete")
        
        aCoder.encode(assessmentCompletedAt, forKey: "assessmentCompletedAt")
    }
}
