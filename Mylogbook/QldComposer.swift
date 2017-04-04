 
 import Foundation
 
 // MARK: Queensland Composer
 
 class QldComposer: LogbookComposer {
    
    var styleTemplate = ""
    
    var htmlTemplate = ""
    
    var rowTemplate = ""
    
    var subtotalRowTemplate: String? = nil
    
    var numberOfTrips = 0

    var units: NSCalendar.Unit = [.minute]

    var accreditedTotal = 0
    
    var dayTotal = 0
    
    var nightTotal = 0
    
    var bonusRemaining: Int = {
        let dayBonus = Cache.shared.currentEntries.dayBonus
        let nightBonus = Cache.shared.currentEntries.nightBonus
        
        return (Cache.shared.residingState.totalBonusAvailable - (dayBonus ?? 0) - (nightBonus ?? 0))
    }()
    
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
        
        if (index > 1 && index % 8 == 0) || (index == (numberOfTrips - 1)) {
            appendSubtotal(onto: &row)
            
            accreditedTotal = 0
            dayTotal = 0
            nightTotal = 0
        }
        
        return row
    }
    
    private func insertLoggedTime(for trip: Trip, into row: inout String) {
        let calculation = TripCalculator.calculate(for: trip)
        
        var accredited = ""
        var day = ""
        var night = ""
        
        if bonusRemaining > 0 && trip.supervisor.isAccredited {
            let bonus = TripCalculator.calculateBonus(for: calculation.total, bonusRemaining: &bonusRemaining)
            
            accredited = bonus.duration(in: units)
            accreditedTotal += bonus
        } else if calculation.day > 0 {
            day = calculation.day.duration(in: units)
            dayTotal += calculation.day
        } else if calculation.night > 0 {
            night = calculation.night.duration(in: units)
            nightTotal += calculation.night
        }
        
        row = row.replacingOccurrences(of: "#TOTAL_TIME#", with: trip.totalTimeInterval.duration(in: units))
        row = row.replacingOccurrences(of: "#ACCREDITED_TIME#", with: accredited)
        row = row.replacingOccurrences(of: "#DAY_TIME#", with: day)
        row = row.replacingOccurrences(of: "#NIGHT_TIME#", with: night)
    }
    
    private func appendSubtotal(onto row: inout String) {
        var subtotalRow = subtotalRowTemplate!
        
        subtotalRow = subtotalRow.replacingOccurrences(of: "#ACCREDITED_TOTAL#", with: accreditedTotal.duration(in: units))
        subtotalRow = subtotalRow.replacingOccurrences(of: "#DAY_TOTAL#", with: dayTotal.duration(in: units))
        subtotalRow = subtotalRow.replacingOccurrences(of: "#NIGHT_TOTAL#", with: nightTotal.duration(in: units))
        
        row += subtotalRow
    }
 }
