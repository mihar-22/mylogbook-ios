
import Foundation
import MapKit

// MARK: Date

extension Date {
    enum DateFormat: String {
        case date = "yyyy-MM-dd"
        case dateTime = "yyyy-MM-dd HH:mm:ss"
    }
    
    func string(format: DateFormat) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: self)
    }
    
    func string(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = date
        
        formatter.timeStyle = time
        
        return formatter.string(from: self)
    }
    
    func secondsFromStartOfDay(in timeZone: TimeZone) -> Int {
        let components = Calendar.current.dateComponents(in: timeZone, from: self)
        
        let hour = components.hour!
        
        let mins = components.minute!
        
        let secs = components.second!
        
        return (hour * (secsPerHour: 3_600)) + (mins * (secsPerMin: 60)) + secs
    }
}

// MARK: String

extension String {
    func date(format: Date.DateFormat) -> Date {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: self)!
    }
}

// MARK: Double

extension Double {
    func distance(style: MKDistanceFormatterUnitStyle = .abbreviated) -> String {
        let formatter = MKDistanceFormatter()
        
        formatter.unitStyle = style
        
        return formatter.string(for: self)!
    }
    
    func distance(in units: MKDistanceFormatterUnits,
                style: MKDistanceFormatterUnitStyle = .abbreviated) -> String {
        
        let formatter = MKDistanceFormatter()
        
        formatter.units = units
        
        formatter.unitStyle = style
        
        return formatter.string(for: self)!
    }
        
    func round(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}

// MARK: Time Interval

extension TimeInterval {
    func time(style: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = style
        
        return formatter.string(from: self)!
    }
    
    func time(in units: NSCalendar.Unit,
              style: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        
        let formatter = DateComponentsFormatter()
        
        formatter.allowedUnits = units

        formatter.unitsStyle = style
        
        return formatter.string(from: self)!
    }    
}
