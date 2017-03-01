
import Solar

// MARK: Trip Calculator

// NOTE: All Calculations are in seconds

struct TripCalculator {
    static func calculateTotal(forAll trips: [Trip]) -> (Int, Int) {
        var totalDayTime = 0
        
        var totalNightTime = 0
        
        for trip in trips {
            let (dayTime, nightTime) = calculate(for: trip)
            
            totalDayTime += dayTime
            
            totalNightTime += nightTime
        }
        
        return (totalDayTime, totalNightTime)
    }
    
    private static func calculate(for trip: Trip) -> (Int, Int) {
        let startedAt = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let endedAt = startedAt + Int(trip.totalTimeInterval)
        
        let (dayStartsAt, dayEndsAt) = getSunriseAndSunset(for: trip)
        
        let secondsPerDay = 86400
        
        let days = endedAt / secondsPerDay
        
        var totalDay = 0
        
        var totalNight = 0
        
        for day in 0 ... days {
            let start = (day == 0) ? startedAt : (secondsPerDay * day)
            
            let end = (day == days) ? endedAt : (secondsPerDay * (day + 1))
            
            let dayStart =  dayStartsAt + (secondsPerDay * day)
            
            let dayEnd =  dayEndsAt + (secondsPerDay * day)
            
            totalDay += max(0, min(end, dayEnd) - max(start, dayStart))
            
            totalNight += max(0, end - dayEnd) + max(0, min(end, dayStart) - start)
        }
        
        return (totalDay, totalNight)
    }
    
    private static func getSunriseAndSunset(for trip: Trip) -> (Int, Int) {
        let solar = Solar.init(forDate: trip.startedAt,
                               withTimeZone: trip.timeZone,
                               latitude: trip.latitude,
                               longitude: trip.longitude)!
        
        let nauticalSunrise = solar.nauticalSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        
        let nauticalSunset = solar.nauticalSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return (nauticalSunrise, nauticalSunset)
    }
}
