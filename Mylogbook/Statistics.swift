
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
    
    private var isStateNewSouthWhales: Bool {
        return Cache.shared.residingState.is(.newSouthWhales)
    }
    
    private var isBonusCreditsAvailable: Bool {
        return Cache.shared.residingState.isBonusCreditsAvailable
    }
    
    // MARK: Initializers
    
    override init() { super.init() }
    
    // MARK: Public Data
    
    var numberOfTrips = 0
    
    var totalLogged: Int {
        return dayLogged + nightLogged
    }

    var dayLogged: Int {
        let dayLogged = day + entries.day
        
        return isBonusCreditsAvailable ? (dayLogged + calculateDayBonus()) : dayLogged
    }
    
    var nightLogged: Int {
        let nightLogged = night + entries.night
        
        return isBonusCreditsAvailable ? (nightLogged + calculateNightBonus()) : nightLogged
    }
    
    func occurrences(of key: String) -> Int? {
        return occurrences[key]
    }
    
    // MARK: Calculations
    
    func calculate() {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                Where("isAccumulated = false"),
                                                OrderBy(.ascending("startedAt")))!
        
        guard trips.count > 0 else { return }
        
        calculateTime(for: trips)
        
        calculateOccurrences(for: trips)
        
        numberOfTrips += trips.count

        TripStore.accumulated(trips)
        
        Cache.shared.save()
    }
    
    private func calculateOccurrences(for trips: [Trip]) {
        func increment(for key: String) {
            let currentValue = occurrences[key] ?? 0
         
            let count = trips.filter({ $0.value(forKey: key) as! Bool }).count
            
            occurrences[key] = (currentValue + count)
        }
        
        for key in ChartSegment.Weather.all { increment(for: key.rawValue.camelCased()) }
        
        for key in ChartSegment.Traffic.all { increment(for: key.rawValue.camelCased()) }
        
        for key in ChartSegment.Road.all { increment(for: key.rawValue.camelCased()) }
    }
    
    private func calculateTime(for trips: [Trip]) {
        var bonusRemaining = calculateBonusRemaining()
        
        for trip in trips {
            let calculation = TripCalculator.calculate(for: trip)
            
            day += calculation.day
            
            night += calculation.night

            calculateBonus(for: trip, with: calculation, bonusRemaining: &bonusRemaining)
        }
    }
    
    private func calculateBonus(for trip: Trip,
                                with calculation: TripCalculation,
                                bonusRemaining: inout Int) {
        
        guard bonusRemaining > 0 && trip.supervisor.isAccredited else { return }

        func calculateBonus(for value: Int) -> Int {
            let bonus = min(value * 2, bonusRemaining)
            
            bonusRemaining -= bonus
            
            return bonus
        }
        
        let start = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let isDayBonusFirst = start >= calculation.sunrise && start <= calculation.sunset
        
        var dayBonus = 0
        
        var nightBonus = 0
        
        if isDayBonusFirst {
            dayBonus = calculateBonus(for: calculation.day)
            
            nightBonus = calculateBonus(for: calculation.night)
        } else {
            nightBonus = calculateBonus(for: calculation.night)
            
            dayBonus = calculateBonus(for: calculation.day)
        }
        
        dayBonus += dayBonus
        
        nightBonus += nightBonus
    }
    
    private func calculateDayBonus() -> Int {
        let dayBonusEntry = (entries.dayBonus ?? 0) * 3
        
        let nightBonusEntry = (entries.nightBonus ?? 0) * 3
        
        guard !isStateNewSouthWhales else {
            let total = dayBonus + dayBonusEntry + (nightBonusEntry * 2/3)
            
            return (entries.isSaferDriversComplete ?? false) ? (total + 72_000) : total
        }
        
        return dayBonus + dayBonusEntry
    }
    
    private func calculateNightBonus() -> Int {
        guard !isStateNewSouthWhales else { return 0 }
        
        return nightBonus + ((entries.nightBonus ?? 0) * 3)
    }
    
    private func calculateBonusRemaining() -> Int {
        var dayBonus = calculateDayBonus()
        
        let nightBonus = calculateNightBonus()
        
        if isStateNewSouthWhales && (entries.isSaferDriversComplete ?? false) {
            dayBonus -= 72_000
        }
        
        return max(0, (72_000 - dayBonus - nightBonus))
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
