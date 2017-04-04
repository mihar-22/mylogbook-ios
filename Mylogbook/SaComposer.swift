 
 import Foundation
 
 // MARK: South Australia Composer
 
 class SaComposer: LogbookComposer {
    
    var styleTemplate = ""
    
    var htmlTemplate = ""
    
    var rowTemplate = ""
    
    var subtotalRowTemplate: String? = nil
    
    var numberOfTrips = 0
    
    var units: NSCalendar.Unit = [.minute]
    
    var totalMinutes = 0
    
    var version: Version

    enum Version {
        case day, night
    }
    
    // MARK: Initializers
    
    required init(version: Version) {
        self.version = version
        
        loadHTMLTemplates()
    }
    
    // MARK: Render Rows
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String {
        var row = rowTemplate
        
        insertID(forRowAt: index, into: &row)
        insertDate(for: trip, into: &row)
        insertTime(for: trip, into: &row)
        insertLoggedTime(for: trip, into: &row)
        insertLocation(for: trip, into: &row)
        insertRoads(for: trip, into: &row)
        insertWeather(for: trip, into: &row)
        insertTraffic(for: trip, into: &row)
        insertSupervisor(for: trip, into: &row)
        
        if (index > 1 && index % 14 == 0) || (index == (numberOfTrips - 1)) {
            appendSubtotal(onto: &row)
            
            totalMinutes = 0
        }
        
        return row
    }
    
    private func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)
        
        var minutes = 0
        
        switch version {
        case .day:
            minutes = calculation.day
        case .night:
            minutes = calculation.night
        }
        
        row = row.replacingOccurrences(of: "#MINUTES#", with: minutes.duration(in: units))
        
        totalMinutes += minutes
    }
    
    private func insertRoads(for trip: Trip, into row: inout String) {
        var roads = ""
        
        if trip.roads.containsAny(Road.unsealed) { roads.add("U") }
        if trip.roads.contains(Road.localStreet) && trip.traffic.contains(Traffic.light) { roads.add("Q") }
        
        if trip.roads.containsAny(Road.sealed) && (trip.traffic.contains(Traffic.moderate) ||
                                                   trip.traffic.contains(Traffic.heavy)) {
            
            roads.add("B")
        }
        
        if trip.roads.containsAny(Road.sealed) {
            roads.add("S")
            
            roads.add("ML")
        }
        
        row = row.replacingOccurrences(of: "#ROADS#", with: roads)
    }
    
    private func insertWeather(for trip: Trip, into row: inout String) {
        var weather = ""
        
        if trip.weather.containsAny(Weather.dry) { weather.add("D") }
        if trip.weather.containsAny(Weather.wet) { weather.add("W") }
        
        row = row.replacingOccurrences(of: "#WEATHER#", with: weather)
    }
    
    private func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        subtotalRow = subtotalRow.replacingOccurrences(of: "#TOTAL#", with: totalMinutes.duration(in: units))
        
        row += subtotalRow
    }
 }
