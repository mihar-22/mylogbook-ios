
import UIKit

// MARK: Chart Settable

protocol ChartSettable {
    var label: String { get }
    
    var color: UIColor { get }
    
    var data: Double { get }
}

extension ChartSettable where Self: RawRepresentable, Self.RawValue == String {
    var label: String {
        return rawValue
    }
    
    var data: Double {        
        return Double(Cache.shared.statistics.occurrences(of: rawValue) ?? 0)
    }
}

// MARK: Chart Segment

enum ChartSegment {
    case weather, traffic, road
    
    var all: [ChartSettable] {
        switch self {
        case .weather:
            return TripCondition.Weather.all
        case .traffic:
            return TripCondition.Traffic.all
        case .road:
            return TripCondition.Road.all
        }
    }
}
