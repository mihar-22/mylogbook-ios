 
 import Foundation
 
 // MARK: Victoria Composer
 
 class VicComposer: LogbookComposer {
    
    var styleTemplate: String = ""
    
    var htmlTemplate: String = ""
    
    var rowTemplate: String = ""
    
    var subtotalRowTemplate: String? = nil
    
    var total = 0
    
    var nightTotal = 0
    
    // MARK: Initializers
    
    required init() { loadHTMLTemplates() }
    
    // MARK: Render Rows
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String {
        var row = rowTemplate
        
        insertID(forRowAt: index, into: &row)
        insertDate(for: trip, into: &row)
        insertTime(for: trip, into: &row)
        insertOdometer(for: trip, into: &row)
        insertRegno(for: trip, into: &row)
        insertSupervisor(for: trip, into: &row)
        insertLoggedTime(for: trip, into: &row)
        insertLoggedTotal(into: &row)
        insertWeather(for: trip, into: &row)
        insertTraffic(for: trip, into: &row)
        insertRoads(for: trip, into: &row)
        insertLight(for: trip, into: &row)
        
        return row
     }
     
    private func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)

        let units: NSCalendar.Unit = [.hour, .minute]

        row = row.replacingOccurrences(of: "#ALL_TIME#", with: calculation.total.duration(in: units))
        row = row.replacingOccurrences(of: "#NIGHT_TIME#", with: calculation.night.duration(in: units))

        self.total += calculation.total
        
        self.nightTotal += calculation.night
    }
    
    func insertLoggedTotal(into row: inout String) {
        let units: NSCalendar.Unit = [.hour, .minute]

        row = row.replacingOccurrences(of: "#ALL_SUM#", with: total.duration(in: units))
        row = row.replacingOccurrences(of: "#NIGHT_SUM#", with: nightTotal.duration(in: units))
    }

    private func insertWeather(for trip: Trip, into row: inout String) {
        var weather = ""

        if trip.weather.containsAny(Weather.dry) { weather.add("D") }
        if trip.weather.containsAny(Weather.wet) { weather.add("W") }

        row = row.replacingOccurrences(of: "#WEATHER#", with: weather)
    }

    private func insertRoads(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#ROADS#", with: trip.roads)
    }

    private func insertLight(for trip: Trip, into row: inout String) {
        var light = ""
        
        if trip.light.contains(Light.day) { light.add("D") }
        if trip.light.contains(Light.dawn) || trip.light.contains(Light.dusk) { light.add("K") }
        if trip.light.contains(Light.night) { light.add("N") }
        
        row = row.replacingOccurrences(of: "#LIGHT#", with: light)
    }
 }
