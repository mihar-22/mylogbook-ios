 
 import Foundation
 
 // MARK: New South Whales Composer
 
 class NswComposer: LogbookComposer {
    var rowTemplate = ""
    
    var subtotalRowTemplate: String? = nil
    
    var numberOfRows = 0
    
    var units: NSCalendar.Unit = [.hour, .minute]
    
    var dayTotal = 0
    
    var nightTotal = 0
    
    var bonusRemaining: Int = {
        let dayBonus = Cache.shared.currentEntries.dayBonus
        let nightBonus = Cache.shared.currentEntries.nightBonus
        
        return (Cache.shared.residingState.totalBonusAvailable - (dayBonus ?? 0) - (nightBonus ?? 0))
    }()
    
    // MARK: Render Row
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String {
        var row = rowTemplate
        
        insertID(forRowAt: index, into: &row)
        insertDate(for: trip, into: &row)
        insertRegno(for: trip, into: &row)
        insertOdometer(for: trip, into: &row)
        insertLocation(for: trip, into: &row)
        insertRoads(for: trip, into: &row)
        insertWeather(for: trip, into: &row)
        insertTraffic(for: trip, into: &row)
        insertSupervisor(for: trip, into: &row)
        insertTime(for: trip, into: &row)
        insertLoggedTime(for: trip, into: &row)
        
        if (index > 1 && index % 7 == 0) || (index == (numberOfRows - 1)){ appendSubtotal(onto: &row) }
        
        return row
    }
    
    // MARK: Insertions
    
    private func insertRoads(for trip: Trip, into row: inout String) {
        var roads = ""

        if trip.roads.containsAny(Road.sealed) { roads.add("S") }
        if trip.roads.containsAny(Road.unsealed) { roads.add("U") }
        if trip.roads.contains(Road.localStreet) && trip.traffic.contains(Traffic.light) { roads.add("QS") }
        if trip.roads.contains(Road.mainRoad) { roads.add("MR") }
        if trip.roads.containsAny(Road.multiLaned) { roads.add("ML") }
        
        row = row.replacingOccurrences(of: "#ROADS#", with: roads)
    }
    
    private func insertWeather(for trip: Trip, into row: inout String) {
        var weather = ""
        
        if trip.weather.contains(Weather.clear) { weather.add("F") }
        if trip.weather.contains(Weather.rain) { weather.add("R") }
        if trip.weather.contains(Weather.snow) { weather.add("S") }
        if trip.weather.contains(Weather.hail) { weather.add("I") }
        if trip.weather.contains(Weather.fog) { weather.add("FG") }
        
        row = row.replacingOccurrences(of: "#WEATHER#", with: weather)
    }
    
    private func insertLoggedTime(for trip: Trip, into row: inout String) {
        var calculation = TripCalculator.calculate(for: trip)
        
        if bonusRemaining > 0 && trip.supervisor.isAccredited {
            let dayBonus = TripCalculator.calculateBonus(for: calculation.day, bonusRemaining: &bonusRemaining)
            let nightBonus = TripCalculator.calculateBonus(for: calculation.night, bonusRemaining: &bonusRemaining)
            
            calculation.day += (dayBonus + nightBonus)
        }
        
        row = row.replacingOccurrences(of: "#DAY_TIME#", with: calculation.day.duration(in: units))
        row = row.replacingOccurrences(of: "#NIGHT_TIME#", with: calculation.night.duration(in: units))
        
        dayTotal += calculation.day
        nightTotal += calculation.night
    }
    
    private func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        subtotalRow = subtotalRow.replacingOccurrences(of: "#DAY_TOTAL#", with: dayTotal.duration(in: units))
        subtotalRow = subtotalRow.replacingOccurrences(of: "#NIGHT_TOTAL#", with: nightTotal.duration(in: units))
        
        row += subtotalRow
    }
 }
