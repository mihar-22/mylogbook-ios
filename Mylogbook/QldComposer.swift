 
 import Foundation
 
 // MARK: Nsw Composer
 
 class QldComposer: LogbookComposer {
    
    var styleTemplate: String = ""
    
    var htmlTemplate: String = ""
    
    var rowTemplate: String = ""
    
    var subtotalRowTemplate: String? = nil
    
    var accreditedTotal = 0
    
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
        insertLocation(for: trip, into: &row)
        insertOdometer(for: trip, into: &row)
        insertSupervisor(for: trip, into: &row)
        insertTime(for: trip, into: &row)
        insertLoggedTime(for: trip, into: &row)
        
        if index > 1 && index % 8 == 0 {
            appendSubtotal(onto: &row)
            
            accreditedTotal = 0
            dayTotal = 0
            nightTotal = 0
        }
        
        return row
    }
    
    func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)
        
        let units: NSCalendar.Unit = [.minute]
        
        row = row.replacingOccurrences(of: "#TOTAL_TIME#", with: calculation.total.duration(in: units))
        
        if trip.supervisor.isAccredited {
           // row = row.replacingOccurrences(of: "#ACCREDITED_TIME#", with: c)
        } else if calculation.day > 0 {
            
        } else if calculation.night > 0 {
            
        }
    }
    
    func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        row += subtotalRow
    }
 }
