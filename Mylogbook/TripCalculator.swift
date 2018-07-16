
import Solar
import CoreLocation

// MARK: Trip Calculation

struct TripCalculation {
    var day: Int
    var night: Int
    
    var total: Int {
        return day + night
    }
}

// MARK: Light Result

struct LightResult {
    var dawn: Bool = false
    var day: Bool = false
    var dusk: Bool = false
    var night: Bool = false
}

// MARK: Twilight

struct Twilight {
    let civilDawn: Int
    let civilDusk: Int
    let nauticalDawn: Int
    let nauticalDusk: Int
    let astronomicalDawn: Int
    let astronomicalDusk: Int
}

// MARK: Trip Calculator

struct TripCalculator {
    
    // MARK: Calculate Time
    
    static func calculate(for trip: Trip) -> TripCalculation {
        let start = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        let end = trip.endedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let (sunrise, sunset) = calculateDayTime(for: trip)
        
        let secondsPerDay = 86_400
        
        let days = (start + Int(trip.totalTimeInterval)) / secondsPerDay
        
        var totalDay = 0
        var totalNight = 0
        
        for day in 0 ... days {
            let start = (day == 0) ? start : 0
            let end = (day == days) ? end : secondsPerDay
            
            totalDay += max(0, min(end, sunset) - max(start, sunrise))
            totalNight += max(0, end - max(start, sunset)) + max(0, min(end, sunrise) - start)
        }
        
        return TripCalculation(day: totalDay, night: totalNight)
    }
    
    // MARK: Calculate Bonus
    
    static func calculateBonus(for value: Int, bonusRemaining: inout Int) -> Int {
        guard bonusRemaining > 0 else { return 0 }
        
        let bonus = min(bonusRemaining, value * Cache.shared.residingState.bonusMultiplier)
        
        bonusRemaining -= bonus
        
        return bonus
    }
    
    // MARK: Calculate Light Conditions
    
    static func calculateLightConditions(for trip: Trip) -> LightResult {
        let start = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        let end = trip.endedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let twilight = calculateTwilight(for: trip)
        
        let secondsPerDay = 86_400
        
        let days = (start + Int(trip.totalTimeInterval)) / secondsPerDay
        
        let dawn = twilight.astronomicalDawn ... twilight.civilDawn
        let day = twilight.civilDawn ... twilight.civilDusk
        let dusk = twilight.civilDusk ... twilight.astronomicalDusk
        let earlyNight = twilight.astronomicalDusk ... 86_400
        let lateNight = 0 ... twilight.astronomicalDawn
        
        var result = LightResult()
        
        for _day in 0 ... days {
            let start = (_day == 0) ? start : 0
            let end = (_day == days) ? end : secondsPerDay
            
            let trip = start ... end
            
            if !result.dawn { result.dawn = trip.overlaps(dawn) }
            if !result.day { result.day = trip.overlaps(day) }
            if !result.dusk { result.dusk = trip.overlaps(dusk) }
            if !result.night { result.night = (trip.overlaps(earlyNight) || trip.overlaps(lateNight)) }
        }
        
        return result
    }
    
    // MARK: Calculate Day Time
    
    static func calculateDayTime(for trip: Trip) -> (sunrise: Int, sunset: Int) {
        let solar = Solar.init(for: trip.startedAt, coordinate: trip.startCoordinate)!
        
        let sunrise = solar.civilSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        let sunset = solar.civilSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return (sunrise, sunset)
    }
    
    // MARK: Calculate Twilight
    
    static func calculateTwilight(for trip: Trip) -> Twilight {
        let solar = Solar.init(for: trip.startedAt, coordinate: trip.startCoordinate)!
        
        let civilDawn = solar.civilSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        let civilDusk = solar.civilSunset!.secondsFromStartOfDay(in: trip.timeZone)
        let nauticalDawn = solar.nauticalSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        let nauticalDusk = solar.nauticalSunset!.secondsFromStartOfDay(in: trip.timeZone)
        let astronomicalDawn = solar.astronomicalSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        let astronomicalDusk = solar.astronomicalSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return Twilight(civilDawn: civilDawn,
                        civilDusk: civilDusk,
                        nauticalDawn: nauticalDawn,
                        nauticalDusk: nauticalDusk,
                        astronomicalDawn: astronomicalDawn,
                        astronomicalDusk: astronomicalDusk)
    }
}



