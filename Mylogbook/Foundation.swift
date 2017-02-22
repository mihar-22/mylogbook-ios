
import Foundation

// MARK: Date

extension Date {
    var dateTime: String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
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
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
    }
}
