
import Foundation
import MapKit

// MARK: Date

extension Date {
    var dateTime: String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: self)
    }
    
    var shortTime: String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .none
        
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
    
    func secondsFromStartOfDay(in timeZone: TimeZone) -> Int {
        let components = Calendar.current.dateComponents(in: timeZone, from: self)
        
        let hour = components.hour!
        
        let mins = components.minute!
        
        let secs = components.second!
        
        return (hour * (secsPerHour: 3600)) + (mins * (secsPerMin: 60)) + secs
    }
}

// MARK: String

extension String {
    var dateTime: Date? {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: self)
    }
}

// MARK: Double

extension Double {
    var abbreviatedDistance: String? {
        let formatter = MKDistanceFormatter()
        
        formatter.units = .metric
        
        formatter.unitStyle = .abbreviated
        
        return formatter.string(for: self)
    }
        
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}

// MARK: Time Interval

extension TimeInterval {
    var abbreviatedTime: String? {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: self)
    }
    
    func abbreviatedTime(in units: NSCalendar.Unit) -> String? {
        let formatter = DateComponentsFormatter()
        
        formatter.unitsStyle = .abbreviated
        
        formatter.allowedUnits = units
        
        return formatter.string(from: self)
    }
}
