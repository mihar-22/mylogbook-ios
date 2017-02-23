
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
    
    var toMeters: Double {
        return self * (kmToMeters: 1000.0)
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
}
