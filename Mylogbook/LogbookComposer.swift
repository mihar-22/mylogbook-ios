
import CoreStore
import CoreLocation
import Foundation

// MARK: LogbookComposer

protocol LogbookComposer: class {
    var styleTemplate: String { get set }
    
    var htmlTemplate: String { get set }
    
    var rowTemplate: String { get set }
    
    var subtotalRowTemplate: String? { get set }
    
    init()
        
    func renderHTML() -> String
    
    func renderHTMLRows() -> String
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String
}

extension LogbookComposer {    
    func loadHTMLTemplates() {
        let state = Cache.shared.residingState.abbreviated
        
        var basePath = "tables/\(state)/"
        
        if Cache.shared.residingState.is(.tasmania) {
            basePath += (Cache.shared.currentEntries.isAssessmentComplete ?? false) ? "L2/tas-L2" : "L1/tas-L1"
        } else {
            basePath += "\(state)"
        }
        
        let htmlURL = Bundle.main.url(forResource: "\(basePath)", withExtension: "html")!
        
        let rowURL = Bundle.main.url(forResource: "\(basePath)-row", withExtension: "html")!
        
        let styleURL = Bundle.main.url(forResource: "tables/style", withExtension: "css")!
        
        htmlTemplate = try! String(contentsOf: htmlURL)
        
        rowTemplate = try! String(contentsOf: rowURL)
        
        styleTemplate = try! String(contentsOf: styleURL)
        
        if !Cache.shared.residingState.is(.victoria) {
            let subtotalRowURL = Bundle.main.url(forResource: "\(basePath)-subtotal-row", withExtension: "html")!
            
            subtotalRowTemplate = try! String(contentsOf: subtotalRowURL)
        }
    }
    
    func renderHTML() -> String {
        var html = htmlTemplate
        
        let rows = renderHTMLRows()

        html = html.replacingOccurrences(of: "#TABLE_BODY#", with: rows)
        
        html = html.replacingOccurrences(of: "#STYLE#", with: styleTemplate)
        
        return html
    }
    
    func renderHTMLRows() -> String {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                OrderBy(.ascending("startedAt")))!
        var rows = ""
        
        for (index, trip) in trips.enumerated() {
            let row = renderHTMLRow(forRowAt: index, with: trip)
            
            rows += row
        }
        
        return rows
    }
}

// MARK: Insertions

extension LogbookComposer {
    func insertID(forRowAt index: Int, into row: inout String) {
        row = row.replacingOccurrences(of: "#ID#", with: "\(index + 1)")
    }
    
    func insertDate(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#DATE#", with: trip.startedAt.utc(format: .date))
    }
    
    func insertTime(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#TIME_START#",
                                       with: trip.startedAt.local(date: .none, time: .short))
        
        row = row.replacingOccurrences(of: "#TIME_END#",
                                       with: trip.endedAt.local(date: .none, time: .short))
    }
    
    func insertOdometer(for trip: Trip, into row: inout String) {
        let formatter = ValueFormatter()
        
        let odometerStart = trip.odometer
        
        let odometerEnd = odometerStart + Int(trip.distance)
        
        let odometerStartFormatted = formatter.string(from: NSNumber(value: odometerStart))
        
        let odometerEndFormatted = formatter.string(from: NSNumber(value: odometerEnd))
        
        row = row.replacingOccurrences(of: "#ODOMETER_START#", with: odometerStartFormatted)
        
        row = row.replacingOccurrences(of: "#ODOMETER_END#", with: odometerEndFormatted)
    }
    
    func insertRegno(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#REGNO#", with: trip.car.registration)
    }
    
    func insertSupervisor(for trip: Trip, into row: inout String) {
        let name = trip.supervisor.name.truncate(length: 20)
        
        row = row.replacingOccurrences(of: "#SUPERVISOR#", with: name)
    }
    
    func insertTraffic(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#TRAFFIC#", with: trip.traffic)
    }
}
