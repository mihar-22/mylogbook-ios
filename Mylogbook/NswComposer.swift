 
 import Foundation
 
 // MARK: Nsw Composer
 
 class NswComposer: LogbookComposer {
    
    var styleTemplate: String = ""
    
    var htmlTemplate: String = ""
    
    var rowTemplate: String = ""
    
    var subtotalRowTemplate: String? = nil
    
    var allTotal = 0
    
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
        
        return row
    }
 }
