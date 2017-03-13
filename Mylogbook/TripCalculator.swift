
import Solar

// MARK: Trip Calculation

struct TripCalculation {
    var day: Int
    var night: Int
    var sunrise: Int
    var sunset: Int
}

// MARK: Trip Calculator

struct TripCalculator {
    static func calculate(for trip: Trip) -> TripCalculation {
        let startedAt = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let endedAt = startedAt + Int(trip.totalTime)
        
        let (sunrise, sunset) = calculateDayTime(for: trip)
        
        let secondsPerDay = 86_400
        
        let days = endedAt / secondsPerDay
        
        var totalDay = 0
        
        var totalNight = 0
        
        for day in 0 ... days {
            let start = (day == 0) ? startedAt : (secondsPerDay * day)
            
            let end = (day == days) ? endedAt : (secondsPerDay * (day + 1))
            
            let _sunrise = sunrise + (secondsPerDay * day)
            
            let _sunset = sunset + (secondsPerDay * day)
            
            totalDay += max(0, min(end, _sunset) - max(start, _sunrise))
            
            totalNight += max(0, end - max(start, _sunset)) + max(0, min(end, _sunrise) - start)
        }
        
        return TripCalculation(day: totalDay, night: totalNight, sunrise: sunrise, sunset: sunset)
    }
    
    // MARK: Sunrise + Sunset
    
    private static func calculateDayTime(for trip: Trip) -> (sunrise: Int, sunset: Int) {
        let solar = Solar.init(forDate: trip.startedAt,
                               withTimeZone: trip.timeZone,
                               latitude: trip.latitude,
                               longitude: trip.longitude)!
        
        let sunrise = solar.nauticalSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        
        let sunset = solar.nauticalSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return (sunrise, sunset)
    }
}



