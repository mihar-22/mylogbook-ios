
import UIKit

// MARK: Chart Settable

protocol ChartSettable {
    var label: String { get }
    
    var color: UIColor { get }
    
    func data(for trips: [Trip]) -> Double
}

extension ChartSettable where Self: RawRepresentable, Self.RawValue == String {
    var label: String {
        return rawValue
    }
}

// MARK: Chart Segment

enum ChartSegment {
    case weather, traffic, road
    
    func all() -> [ChartSettable] {
        switch self {
        case .weather:
            return Weather.all
        case .traffic:
            return Traffic.all
        case .road:
            return Road.all
        }
    }
    
    enum Weather: String, ChartSettable {
        case clear = "Clear"
        case rain = "Rain"
        case thunder = "Thunder"
        
        static let all = [clear, rain, thunder]
        
        var color: UIColor {
            switch self {
            case .clear:
                return UIColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 1)
            case .rain:
                return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
            case .thunder:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            }
        }
        
        func data(for trips: [Trip]) -> Double {
            switch self {
            case .clear:
                return Double(trips.filter({ $0.clear }).count)
            case .rain:
                return Double(trips.filter({ $0.rain }).count)
            case .thunder:
                return Double(trips.filter({ $0.thunder }).count)
            }
        }
    }
    
    enum Traffic: String, ChartSettable {
        case light = "Light"
        case moderate = "Moderate"
        case heavy = "Heavy"
        
        static let all = [light, moderate, heavy]
        
        var color: UIColor {
            switch self {
            case .light:
                return UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            case .moderate:
                return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
            case .heavy:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            }
        }
        
        func data(for trips: [Trip]) -> Double {
            switch self {
            case .light:
                return Double(trips.filter({ $0.light }).count)
            case .moderate:
                return Double(trips.filter({ $0.moderate }).count)
            case .heavy:
                return Double(trips.filter({ $0.heavy }).count)
            }
        }
    }
    
    enum Road: String, ChartSettable {
        case localStreet = "Local Street"
        case mainRoad = "Main Road"
        case innerCity = "Inner City"
        case freeway = "Freeway"
        case ruralHighway = "Rural Highway"
        case gravel = "Gravel"
        
        static let all = [localStreet, mainRoad, innerCity, freeway, ruralHighway, gravel]
        
        var color: UIColor {
            switch self {
            case .localStreet:
                return UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            case .mainRoad:
                return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1)
            case .innerCity:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            case .freeway:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            case .ruralHighway:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            case .gravel:
                return UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            }
        }
        
        func data(for trips: [Trip]) -> Double {
            switch self {
            case .localStreet:
                return Double(trips.filter({ $0.localStreet }).count)
            case .mainRoad:
                return Double(trips.filter({ $0.mainRoad }).count)
            case .innerCity:
                return Double(trips.filter({ $0.innerCity }).count)
            case .freeway:
                return Double(trips.filter({ $0.freeway }).count)
            case .ruralHighway:
                return Double(trips.filter({ $0.ruralHighway }).count)
            case .gravel:
                return Double(trips.filter({ $0.gravel }).count)
            }
        }
    }
}
