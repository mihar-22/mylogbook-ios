
import Solar

// MARK: Trip Calculation

struct TripCalculation {
    var day: Int
    var night: Int
    var sunrise: Int
    var sunset: Int
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
    static func calculate(for trip: Trip) -> TripCalculation {
        let start = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let end = start + Int(trip.totalTime)
        
        let (sunrise, sunset) = calculateDayTime(for: trip)
        
        let secondsPerDay = 86_400
        
        let days = end / secondsPerDay
        
        var totalDay = 0
        
        var totalNight = 0
        
        for day in 0 ... days {
            let start = max(start, (secondsPerDay * day))
            
            let end = min(end, (secondsPerDay * (day + 1)))
            
            let sunrise = sunrise + (secondsPerDay * day)
            
            let sunset = sunset + (secondsPerDay * day)
            
            totalDay += max(0, min(end, sunset) - max(start, sunrise))
            
            totalNight += max(0, end - max(start, sunset)) + max(0, min(end, sunrise) - start)
        }
        
        return TripCalculation(day: totalDay, night: totalNight, sunrise: sunrise, sunset: sunset)
    }
    
    // MARK: Calculate Day Time
    
    static func calculateDayTime(for trip: Trip) -> (sunrise: Int, sunset: Int) {
        let solar = Solar.init(forDate: trip.startedAt,
                               withTimeZone: trip.timeZone,
                               latitude: trip.startLatitude,
                               longitude: trip.startLongitude)!
        
        let sunrise = solar.civilSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        
        let sunset = solar.civilSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return (sunrise, sunset)
    }
    
    // MARK: Calculate Twilight
    
    static func calculateTwilight(for trip: Trip) -> Twilight {
        let solar = Solar.init(forDate: trip.startedAt,
                               withTimeZone: trip.timeZone,
                               latitude: trip.startLatitude,
                               longitude: trip.startLongitude)!
        
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



