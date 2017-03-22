
import Foundation
import MapKit

// MARK: Date

extension Date {
    enum Format: String {
        case date = "yyyy-MM-dd"
        case dateTime = "yyyy-MM-dd HH:mm:ss"
    }
    
    func utc(format: Format) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.string(from: self)
    }
    
    func local(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = date
        
        formatter.timeStyle = time
        
        return formatter.string(from: self)
    }
    
    func days(since date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func months(since date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    func years(since date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
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
    func utc(format: Date.Format) -> Date {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: self)!
    }
    
    func truncate(length: Int, trailing: String = "...") -> String {
        guard self.characters.count <= length else {
            let upperbound = self.index(self.startIndex, offsetBy: length)
            
            return self.substring(to: upperbound) + trailing
        }
        
        return self
    }
}

// MARK: String Code Helpers

extension String {
    func contains(_ character: Character) -> Bool {
        return self.characters.contains(character)
    }
    
    func contains(_ condition: TripConditionable) -> Bool {
        return self.characters.contains(condition.code)
    }
    
    func contains(_ conditions: [TripConditionable]) -> Bool {
        for condition in conditions {
            if !self.characters.contains(condition.code) {
                return false
            }
        }
        
        return true
    }
    
    func containsAny(_ conditions: [TripConditionable]) -> Bool {
        for condition in conditions {
            if self.characters.contains(condition.code) {
                return true
            }
        }
        
        return false
    }
    
    mutating func add(_ code: Character) {
        self += self.isEmpty ? "\(code)" : ",\(code)"
    }
    
    mutating func remove(_ code: Character) {
        guard self.characters.contains(code) else {
            return
        }
        
        guard self.characters.count > 1 else {
            self = ""
            
            return
        }
        
        let target = (self.characters.first == code) ? "\(code)," : ",\(code)"
        
        self = self.replacingOccurrences(of: target, with: "")
    }
}

// MARK: Double

extension Double {
    func distance(style: MKDistanceFormatterUnitStyle = .abbreviated) -> String {
        let formatter = MKDistanceFormatter()
        
        formatter.unitStyle = style
        
        formatter.units = .metric
        
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
