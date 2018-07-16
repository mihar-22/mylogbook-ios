
import CoreStore
import CoreLocation
import Foundation

// MARK: LogbookComposer

protocol LogbookComposer: class {
    var rowTemplate: String { get set }
    
    var subtotalRowTemplate: String? { get set }
    
    var numberOfRows: Int { get set }
    
    var units: NSCalendar.Unit { get set }
        
    func renderHTML() -> [String]
    
    func renderHTMLRow(forRowAt index: Int, with trip: Trip) -> String
    
    func createPDF() -> NSData
}

// MARK: Render

extension LogbookComposer {
    var maximumRowsPerPage: Int {
        switch residingState {
        case .queensland, .southAustralia, .victoria:
            return 18
        default:
            return 16
        }
    }
    
    func renderHTML() -> [String] {
        loadRowTemplates()

        let htmlTemplate = getHTMLTemplate()
        let style = getStyleTemplate()

        var tables = [String]()
        
        var rows = ""
        
        for (index, trip) in fetchTrips().enumerated() {
            let row = renderHTMLRow(forRowAt: index, with: trip)
            
            rows += row
            
            if ((index > 1 && ((index + 1) % maximumRowsPerPage == 0)) || (index == (numberOfRows - 1))) {
                var table = htmlTemplate
                
                table = table.replacingOccurrences(of: "#TABLE_BODY#", with: rows)
                table = table.replacingOccurrences(of: "#STYLE#", with: style)
                
                tables.append(table)
                
                rows = ""
            }
        }
        
        return tables
    }
}

// MARK: PDF

extension LogbookComposer {
    var paperRect: CGRect {
        return CGRect(x: 0, y: 0, width: 841.8, height: 595.2)
    }
    
    func createPDF() -> NSData {
        let tables = renderHTML()
        
        let renderer = UIPrintPageRenderer()

        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "printableRect")
        
        for (index, table) in tables.enumerated() {
            let formatter = UIMarkupTextPrintFormatter(markupText: table)
            
            renderer.addPrintFormatter(formatter, startingAtPageAt: index)
        }
        
        return drawPDF(with: renderer)
    }
    
    func drawPDF(with renderer: UIPrintPageRenderer) -> NSData {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, paperRect, nil)
        
        for page in 0 ... (renderer.numberOfPages - 1) {
            UIGraphicsBeginPDFPage()
            
            renderer.drawPage(at: page, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
}

// MARK: Load Resources

extension LogbookComposer {
    var residingState: AustralianState {
        return Cache.shared.residingState
    }
    
    var basePath: String {
        let state = residingState.abbreviated
        
        var basePath = "tables/\(state)/"
        
        if residingState.is(.tasmania) {
            let isL2 = (Cache.shared.currentEntries.isAssessmentComplete ?? false)
            
            basePath += isL2 ? "L2/tas-L2" : "L1/tas-L1"
        } else {
            basePath += "\(state)"
        }
        
        if residingState.is(.westernAustralia) {
            basePath = "tables/tas/L2/tas-L2"
        }
        
        return basePath
    }
    
    func getHTMLTemplate() -> String {
        let htmlURL = Bundle.main.url(forResource: "\(basePath)", withExtension: "html")!
        
        return try! String(contentsOf: htmlURL)
    }
    
    func getStyleTemplate() -> String {
        let styleURL = Bundle.main.url(forResource: "tables/style", withExtension: "css")!
        
        return try! String(contentsOf: styleURL)
    }
    
    func loadRowTemplates() {
        let rowURL = Bundle.main.url(forResource: "\(basePath)-row", withExtension: "html")!
        
        rowTemplate = try! String(contentsOf: rowURL)
        
        if !residingState.is(.victoria) {
            let subtotalRowURL = Bundle.main.url(forResource: "\(basePath)-subtotal-row", withExtension: "html")!
            
            subtotalRowTemplate = try! String(contentsOf: subtotalRowURL)
        }
    }
    
    func fetchTrips() -> [Trip] {
        let trips = Store.shared.stack.fetchAll(From<Trip>(),
                                                OrderBy<Trip>(.ascending("startedAt")))!
        
        numberOfRows = trips.count
        
        return trips
    }
}

// MARK: General Insertions

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
        
        let odometerEnd = Int(odometerStart) + Int(trip.distance / 1000)
        
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
    
    func insertLocation(for trip: Trip, into row: inout String) {
        row = row.replacingOccurrences(of: "#LOCATION_FROM#", with: trip.startLocation.truncate(length: 20))
        row = row.replacingOccurrences(of: "#LOCATION_TO#", with: trip.endLocation.truncate(length: 20))
    }
}
