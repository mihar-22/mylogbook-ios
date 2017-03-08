
import Solar

// MARK: Trip Calculator

struct TripCalculator {
    
    static func calculateTotal(forAll trips: [Trip]) -> (Int, Int) {
        if Settings.shared.residingState.isBonusCreditsAvailable {
            let (totalDay, totalNight) = calculateTotalTime(forAll: trips)
            
            let (dayBonus, nightBonus) = calculateTotalBonus(forAll: trips)
            
            return (totalDay + dayBonus, totalNight + nightBonus)
        }
        
        return calculateTotalTime(forAll: trips)
    }
    
    // MARK: Time Calculations
    
    private static func calculateTotalTime(forAll trips: [Trip]) -> (Int, Int) {
        let settings = Settings.shared.currentEntries

        var totalDay = 0
        
        var totalNight = 0
        
        for trip in trips {
            let (day, night) = calculateTime(for: trip)
            
            totalDay += day
            
            totalNight += night
        }
        
        return (totalDay + settings.day, totalNight + settings.night)
    }
    
    private static func calculateTime(for trip: Trip) -> (Int, Int) {
        let (sunrise, sunset) = calculateSunriseAndSunset(for: trip)
        
        let startedAt = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)
        
        let endedAt = startedAt + Int(trip.totalTime)
        
        let secondsPerDay = 86400
        
        let days = endedAt / secondsPerDay
        
        var totalDay = 0
        
        var totalNight = 0
        
        for day in 0 ... days {
            let start = (day == 0) ? startedAt : (secondsPerDay * day)
            
            let end = (day == days) ? endedAt : (secondsPerDay * (day + 1))
            
            let dayStart =  sunrise + (secondsPerDay * day)
            
            let dayEnd =  sunset + (secondsPerDay * day)
            
            totalDay += max(0, min(end, dayEnd) - max(start, dayStart))
            
            totalNight += max(0, end - dayEnd) + max(0, min(end, dayStart) - start)
        }
        
        return (totalDay, totalNight)
    }
    
    // MARK: Sunrise + Sunset Calculation
    
    private static func calculateSunriseAndSunset(for trip: Trip) -> (Int, Int) {
        let solar = Solar.init(forDate: trip.startedAt,
                               withTimeZone: trip.timeZone,
                               latitude: trip.latitude,
                               longitude: trip.longitude)!
        
        let nauticalSunrise = solar.nauticalSunrise!.secondsFromStartOfDay(in: trip.timeZone)
        
        let nauticalSunset = solar.nauticalSunset!.secondsFromStartOfDay(in: trip.timeZone)
        
        return (nauticalSunrise, nauticalSunset)
    }
    
    // MARK: Bonus Calculations
    
    private static func calculateTotalBonus(forAll trips: [Trip]) -> (Int, Int) {
        let isStateNSW = Settings.shared.residingState.is(.newSouthWhales)
        
        let settings = Settings.shared.currentEntries

        let settingsDayBonus = (settings.dayBonus ?? 0) * 3
        
        let settingsNightBonus = (settings.nightBonus ?? 0) * 3
        
        var totalDayBonus = 0
        
        var totalNightBonus = 0
        
        var bonusRemaining = 36_000 - (settingsDayBonus + settingsNightBonus)
        
        for trip in trips.filter({ $0.supervisor.isAccredited }) {
            guard bonusRemaining > 0 else { break }
            
            let (dayBonus, nightBonus) = calculateBonus(for: trip, bonusRemaining: &bonusRemaining)
            
            totalDayBonus += dayBonus
            
            totalNightBonus += nightBonus
        }
        
        if isStateNSW {
            let isComplete = settings.isSaferDriversComplete
            
            if isComplete != nil && isComplete! { totalDayBonus += 72_000 }
            
            return (totalDayBonus + totalNightBonus + (settingsNightBonus * 2/3), (settingsNightBonus * 1/3))
        }
        
        return (totalDayBonus + settingsDayBonus, totalNightBonus + settingsNightBonus)
    }
    
    private static func calculateBonus(for trip: Trip, bonusRemaining: inout Int) -> (Int, Int) {
        let start = trip.startedAt.secondsFromStartOfDay(in: trip.timeZone)

        let (sunrise, sunset) = calculateSunriseAndSunset(for: trip)
        
        let (day, night) = calculateTime(for: trip)
        
        var dayBonus = 0
        
        var nightBonus = 0
        
        if start >= sunrise && start <= sunset {
            dayBonus = min(day * 2, bonusRemaining)
            
            bonusRemaining -= dayBonus
            
            nightBonus = min(night * 2, bonusRemaining)
            
            bonusRemaining -= nightBonus
        } else {
            nightBonus = min(night * 2, bonusRemaining)
            
            bonusRemaining -= nightBonus
            
            dayBonus = min(day * 2, bonusRemaining)
            
            bonusRemaining -= dayBonus
        }
        
        return (dayBonus, nightBonus)
    }
}
