
import CoreStore
import Foundation

// MARK: Statistics

class Statistics: NSObject, NSCoding {
    private var day = 0
    
    private var night = 0
    
    private var dayBonus = 0
    
    private var nightBonus = 0
    
    private var occurrences = [String: Int]()
    
    private var entries: Entries {
        return Cache.shared.currentEntries
    }
    
    private var residingState: AustralianState {
        return Cache.shared.residingState
    }
    
    private var dayBonusWithEntry: Int {
        guard residingState.isBonusCreditsAvailable else { return 0 }
        
        guard !residingState.is(.newSouthWhales) else {
            return dayBonus + (entries.dayBonus ?? 0) + (entries.nightBonus ?? 0)
        }
        
        return dayBonus + (entries.dayBonus ?? 0)
    }
    
    private var nightBonusWithEntry: Int {
        guard residingState.isBonusCreditsAvailable else { return 0 }
        
        guard !residingState.is(.newSouthWhales) else { return 0 }
        
        return nightBonus + (entries.nightBonus ?? 0)
    }
    
    // MARK: Initializers
    
    override init() { super.init() }
    
    // MARK: Data
    
    var numberOfTrips = 0
    
    var totalLogged: Int {
        return dayLogged + nightLogged
    }

    var dayLogged: Int {
        let dayLogged = day + entries.day + dayBonusWithEntry
                
        guard !residingState.is(.newSouthWhales) else {
            let isTimeSatisfied = (dayLogged + nightLogged) >= AustralianState.timeRequiredForSaferDrivers
            let isComplete = (entries.isSaferDriversComplete ?? false) && isTimeSatisfied
            
            return isComplete ? (dayLogged + AustralianState.saferDriversBonus) : dayLogged
        }
        
        return dayLogged
    }
    
    var nightLogged: Int {
        return night + entries.night + nightBonusWithEntry
    }
    
    var totalBonusEarned: Int {
        return dayBonusWithEntry + nightBonusWithEntry
    }
    
    func occurrences(of key: String) -> Int? {
        return occurrences[key]
    }
    
    // MARK: Refresh
    
    func refresh() {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                Where("isAccumulated = true"),
                                                OrderBy(.ascending("startedAt")))!
        
        day = 0
        night = 0
        dayBonus = 0
        nightBonus = 0
        
        accumulateTime(for: trips)
        
        Cache.shared.save()
    }
    
    // MARK: Update
    
    func update() {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                Where("isAccumulated = false"),
                                                OrderBy(.ascending("startedAt")))!
        
        guard trips.count > 0 else { return }
        
        accumulateTime(for: trips)
        
        accumulateOccurrences(for: trips)
        
        numberOfTrips += trips.count
        
        TripStore.accumulated(trips)
        
        Cache.shared.save()
    }
    
    // MARK: Accumulate
    
    private func accumulateTime(for trips: [Trip]) {
        var bonusRemaining = max(0, (residingState.totalBonusAvailable - dayBonusWithEntry - nightBonusWithEntry))
        
        for trip in trips {
            let calculation = TripCalculator.calculate(for: trip)
            
            day += calculation.day
            night += calculation.night
            
            guard bonusRemaining > 0 && trip.supervisor.isAccredited else { continue }
            
            dayBonus += TripCalculator.calculateBonus(for: calculation.day, bonusRemaining: &bonusRemaining)
            nightBonus += TripCalculator.calculateBonus(for: calculation.night, bonusRemaining: &bonusRemaining)
        }
    }

    private func accumulateOccurrences(for trips: [Trip]) {
        for condition in TripCondition.all {
            let key = condition.rawValue
            
            let currentValue = occurrences[key] ?? 0
            
            let count = trips.filter({ $0.didOccur(condition) }).count
            
            occurrences[key] = (currentValue + count)
        }
    }
    
    // MARK: Encoding + Decoding
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: "day")
        night = aDecoder.decodeInteger(forKey: "night")
        dayBonus = aDecoder.decodeInteger(forKey: "dayBonus")
        nightBonus = aDecoder.decodeInteger(forKey: "nightBonus")
        numberOfTrips = aDecoder.decodeInteger(forKey: "numberOfTrips")
        occurrences = aDecoder.decodeObject(forKey: "occurrences") as! [String : Int]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        aCoder.encode(night, forKey: "night")
        aCoder.encode(dayBonus, forKey: "dayBonus")
        aCoder.encode(nightBonus, forKey: "nightBonus")
        aCoder.encode(numberOfTrips, forKey: "numberOfTrips")
        aCoder.encode(occurrences, forKey: "occurrences")
    }
}
