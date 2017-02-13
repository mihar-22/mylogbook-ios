
import Foundation

// MARK: Date

extension Date {
    var iso8601: String {
        return ISO8601DateFormatter().string(from: self)
    }
}

// MARK: String

extension String {
    var dateFromISO8601: Date? {
        return ISO8601DateFormatter().date(from: self)
    }
}
