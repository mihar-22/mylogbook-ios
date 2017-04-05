 
 import Foundation
 
 // MARK: Tasmania Composer
 
 class TasComposer: LogbookComposer {
    var rowTemplate = ""
    
    var subtotalRowTemplate: String? = nil
    
    var numberOfRows = 0
    
    var units: NSCalendar.Unit = [.minute]
    
    var totalMinutes = 0
    
    var isL2: Bool = {
        return Cache.shared.currentEntries.isAssessmentComplete ?? false
    }()
    
    // MARK: Render Row
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String {
        var row = rowTemplate
        
        insertID(forRowAt: index, into: &row)
        insertDate(for: trip, into: &row)
        insertLoggedTime(for: trip, into: &row)
        insertLocation(for: trip, into: &row)
        insertVisibility(for: trip, into: &row)
        insertWeather(for: trip, into: &row)
        insertTraffic(for: trip, into: &row)
        insertRoads(for: trip, into: &row)
        
        if isL2 {
            insertTime(for: trip, into: &row)
            insertDistance(for: trip, into: &row)
            insertRegno(for: trip, into: &row)
            insertSupervisor(for: trip, into: &row)
        }
        
        if (index > 1 && index % 11 == 0) || (index == (numberOfRows - 1)) {
            appendSubtotal(onto: &row)
            
            totalMinutes = 0
        }
        
        return row
    }
    
    // MARK: Insertions
    
    private func insertDistance(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#DISTANCE#", with: trip.distance.distance())
    }
    
    private func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)
        
        row = row.replacingOccurrences(of: "#MINUTES#", with: calculation.total.duration(in: units))
        
        totalMinutes += calculation.total
    }
    
    private func insertVisibility(for trip: Trip, into row: inout String) {
        var visibility = ""
        
        let light = TripCalculator.calculateLightConditions(for: trip)
        
        if light.dawn || light.dusk { visibility.add("S") }
        if light.day { visibility.add("D") }
        if light.night { visibility.add("N") }
        if trip.weather.contains(Weather.fog) { visibility.add("F") }
        
        row = row.replacingOccurrences(of: "#VISIBILITY#", with: visibility)
    }
    
    private func insertWeather(for trip: Trip, into row: inout String) {
        var weather = ""
        
        if trip.weather.containsAny(Weather.dry) { weather.add("D") }
        if trip.weather.containsAny(Weather.wet) { weather.add("W") }
        if trip.weather.contains(Weather.hail) { weather.add("I") }
        if trip.weather.contains(Weather.snow) { weather.add("S") }
        
        row = row.replacingOccurrences(of: "#WEATHER#", with: weather)
    }
    
    private func insertRoads(for trip: Trip, into row: inout String) {
        var roads = ""
        
        if trip.roads.contains(Road.localStreet) { roads.add("S") }
        if trip.roads.contains(Road.mainRoad) { roads.add("M, H") }
        if trip.roads.contains(Road.ruralRoad) { roads.add("R") }
        if trip.roads.contains(Road.innerCity) { roads.add("C") }
        if trip.roads.contains(Road.gravel) { roads.add("G") }
        
        row = row.replacingOccurrences(of: "#ROADS#", with: roads)
    }
    
    private func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        subtotalRow = subtotalRow.replacingOccurrences(of: "#TOTAL#", with: totalMinutes.duration(in: units))
        
        row += subtotalRow
    }
 }
