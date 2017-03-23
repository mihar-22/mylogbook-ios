
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
    case weather, traffic, road, light
    
    var all: [ChartSettable] {
        switch self {
        case .weather:
            return Weather.all
        case .traffic:
            return Traffic.all
        case .road:
            return Road.all
        case .light:
            return Light.all
        }
    }
}
