
import CoreStore
import Foundation

// MARK: Logbook Composer

class LogbookComposer {
    
    var styleTemplate: String
    
    var htmlTemplate: String
    
    var rowTemplate: String
    
    var lastRowTemplate: String
    
    var residingState: AustralianState {
        return Cache.shared.residingState
    }
    
    var isAssessmentComplete: Bool {
        return (Cache.shared.currentEntries.isAssessmentComplete ?? false)
    }
    
    init() {
        let state = Cache.shared.residingState.abbreviated
        
        var basePath = "tables/\(state)/"
        
        if Cache.shared.residingState.is(.tasmania) {
            basePath += (Cache.shared.currentEntries.isAssessmentComplete ?? false) ? "L2/tas-L2" : "L1/tas-L1"
        } else {
            basePath += "\(state)"
        }
        
        let htmlURL = Bundle.main.url(forResource: "\(basePath)", withExtension: "html")!
        
        let rowURL = Bundle.main.url(forResource: "\(basePath)-row", withExtension: "html")!
        
        let lastRowURL = Bundle.main.url(forResource: "\(basePath)-last-row", withExtension: "html")!

        let styleURL = Bundle.main.url(forResource: "tables/style", withExtension: "css")!
        
        htmlTemplate = try! String(contentsOf: htmlURL)
        
        rowTemplate = try! String(contentsOf: rowURL)
        
        lastRowTemplate = try! String(contentsOf: lastRowURL)
        
        styleTemplate = try! String(contentsOf: styleURL)
    }
    
    // MARK: HTML Rendering
    
    func renderHTML() -> String {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                OrderBy(.ascending("startedAt")))!
        
        var html = htmlTemplate
        
        switch residingState {
        case .victoria:
            renderVictoriaTable(&html, with: trips)
        default:
            break
        }
        
        insertStyle(into: &html)
        
        return html
    }
    
    private func renderVictoriaTable(_ html: inout String, with trips: [Trip]) {
        var rows = ""
        
        for (index, trip) in trips.enumerated() {
            var row = rowTemplate
            
            insertID(forRowAt: index, into: &row)

            insertDate(for: trip, into: &row)
            
            insertTime(for: trip, into: &row)
            
            insertOdometer(for: trip, into: &row)
            
            insertRegno(for: trip, into: &row)
            
            insertSupervisor(for: trip, into: &row)
            
            rows += row
            
            if index % 14 == 0 {
                let lastRow = lastRowTemplate
                
                rows += lastRow
            }
        }
        
        insertRows(rows, into: &html)
    }

    // MARK: Insertions
    
    private func insertStyle(into html: inout String) {
        html = html.replacingOccurrences(of: "#STYLE#", with: styleTemplate)
    }
    
    private func insertRows(_ rows: String, into html: inout String) {
        html = html.replacingOccurrences(of: "#TABLE_BODY#", with: rows)
    }
    
    private func insertID(forRowAt index: Int, into row: inout String) {
        row = row.replacingOccurrences(of: "#ID#", with: "\(index + 1)")
    }
    
    private func insertDate(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#DATE#", with: trip.startedAt.string(format: .date))
    }
    
    private func insertTime(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#TIME_START#", with: trip.startedAt.string(date: .none, time: .short))
        
        row = row.replacingOccurrences(of: "#TIME_END#", with: trip.endedAt.string(date: .none, time: .short))
    }
    
    private func insertOdometer(for trip: Trip, into row: inout String) {
        let formatter = ValueFormatter()
        
        let odometerStart = trip.odometer
        
        let odometerEnd = odometerStart + Int(trip.distance)
        
        let odometerStartFormatted = formatter.string(from: NSNumber(value: odometerStart))
        
        let odometerEndFormatted = formatter.string(from: NSNumber(value: odometerEnd))
        
        row = row.replacingOccurrences(of: "#ODOMETER_START#", with: odometerStartFormatted)
        
        row = row.replacingOccurrences(of: "#ODOMETER_END#", with: odometerEndFormatted)
    }
    
    private func insertRegno(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#REGNO#", with: trip.car.registration)
    }
    
    private func insertSupervisor(for trip: Trip, into row: inout String) {
        let name = trip.supervisor.fullName.truncate(length: 20)
        
        row = row.replacingOccurrences(of: "#SUPERVISOR#", with: name)
    }
}
