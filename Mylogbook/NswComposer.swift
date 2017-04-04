 
 import Foundation
 
 // MARK: Nsw Composer
 
 class NswComposer: LogbookComposer {
    
    var styleTemplate: String = ""
    
    var htmlTemplate: String = ""
    
    var rowTemplate: String = ""
    
    var subtotalRowTemplate: String? = nil
    
    var dayTotal = 0
    
    var nightTotal = 0
    
    // MARK: Initializers
    
    required init() { loadHTMLTemplates() }
    
    // MARK: Render Rows
    
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
        
        if index > 1 && index % 7 == 0 { appendSubtotal(onto: &row) }
        
        return row
    }
    
    func insertRoads(for trip: Trip, into row: inout String) {
        var roads = ""
        
        if trip.roads.containsAny(Road.unsealed) { roads.add("U") }
        if trip.roads.contains(Road.localStreet.code) && trip.traffic.contains(Traffic.light.code) { roads.add("QS") }
        if trip.roads.contains(Road.mainRoad.code) { roads.add("MR") }
        if trip.roads.containsAny(Road.sealed) {
            roads.add("S")
            
            roads.add("ML")
        }
        
        row = row.replacingOccurrences(of: "#ROADS#", with: roads)
    }
    
    func insertWeather(for trip: Trip, into row: inout String) {
        var weather = ""
        
        if trip.weather.contains(Weather.clear.code) { weather.add("F") }
        if trip.weather.contains(Weather.rain.code) { weather.add("R") }
        if trip.weather.contains(Weather.snow.code) { weather.add("S") }
        if trip.weather.contains(Weather.hail.code) { weather.add("I") }
        if trip.weather.contains(Weather.fog.code) { weather.add("FG") }
        
        row = row.replacingOccurrences(of: "#WEATHER#", with: weather)
    }
    
    func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)
        
        let units: NSCalendar.Unit = [.hour, .minute]
        
        row = row.replacingOccurrences(of: "#DAY_TIME#", with: calculation.day.duration(in: units))
        row = row.replacingOccurrences(of: "#NIGHT_TIME#", with: calculation.night.duration(in: units))
        
        dayTotal += calculation.day
        nightTotal += calculation.night
    }
    
    func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        let units: NSCalendar.Unit = [.hour, .minute]
        
        subtotalRow = subtotalRow.replacingOccurrences(of: "#DAY_TOTAL#", with: dayTotal.duration(in: units))
        subtotalRow = subtotalRow.replacingOccurrences(of: "#NIGHT_TOTAL#", with: nightTotal.duration(in: units))
        
        row += subtotalRow
    }
 }
