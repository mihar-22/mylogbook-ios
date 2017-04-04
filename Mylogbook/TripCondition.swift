
import UIKit

// MARK: Trip Conditionable

protocol TripConditionable {
    var code: Character { get }
}

extension TripConditionable where Self: RawRepresentable, Self.RawValue == String {
    var code: Character {
        return rawValue[rawValue.startIndex]
    }
}

// MARK: Trip Conditions

enum TripCondition {
    case weather(Weather), traffic(Traffic), road(Road), light(Light)
    
    var rawValue: String {
        switch self {
        case .weather(let type):
            return type.rawValue
        case .traffic(let type):
            return type.rawValue
        case .road(let type):
            return type.rawValue
        case .light(let type):
            return type.rawValue
        }
    }
    
    static var all: [TripCondition] {
        var all = [TripCondition]()
        
        for type in Weather.all { all.append(.weather(type)) }
        for type in Traffic.all { all.append(.traffic(type)) }
        for type in Road.all { all.append(.road(type)) }
        for type in Light.all { all.append(.light(type)) }
        
        return all
    }
}

// MARK: Weather

enum Weather: String, TripConditionable, ChartSettable {
    case clear = "Clear"
    case rain = "Rain"
    case thunder = "Thunder"
    case fog = "Fog"
    case hail = "Hail"
    case snow = "Snow"
    
    static let all = [clear, rain, thunder, fog, hail, snow]
    
    static var dry: [Weather] {
        return [.clear]
    }
    
    static var wet: [Weather] {
        return [.rain, .hail, .snow]
    }
    
    var color: UIColor {
        switch self {
        case .clear:
            return UIColor(red: 168/255, green: 220/255, blue: 223/255, alpha: 1)
        case .rain:
            return UIColor(red: 125/255, green: 175/255, blue: 222/255, alpha: 1)
        case .thunder:
            return UIColor(red: 243/255, green: 203/255, blue: 87/255, alpha: 1)
        case .fog:
            return UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)
        case .hail:
            return UIColor(red: 178/255, green: 134/255, blue: 165/255, alpha: 1)
        case .snow:
            return UIColor(red: 245/255, green: 147/255, blue: 146/255, alpha: 1)
        }
    }
}

// MARK: Traffic

enum Traffic: String, TripConditionable, ChartSettable {
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    
    static let all = [light, moderate, heavy]
    
    var color: UIColor {
        switch self {
        case .light:
            return UIColor(red: 121/255, green: 196/255, blue: 121/255, alpha: 1)
        case .moderate:
            return UIColor(red: 236/255, green: 190/255, blue: 95/255, alpha: 1)
        case .heavy:
            return UIColor(red: 211/255, green: 106/255, blue: 106/255, alpha: 1)
        }
    }
}

// MARK: Light

enum Light: String, TripConditionable, ChartSettable {
    case dawn = "Dawn"
    case day = "Day"
    case dusk = "Dusk"
    case night = "Night"
    
    static let all = [dawn, day, dusk, night]
    
    var code: Character {
        switch self {
        case .day:
            return "D"
        case .dawn:
            return "W"
        case .dusk:
            return "K"
        case .night:
            return "N"
        }
    }
    
    var color: UIColor {
        switch self {
        case .day:
            return UIColor(red: 243/255, green: 203/255, blue: 87/255, alpha: 1)
        case .dawn:
            return UIColor(red: 168/255, green: 220/255, blue: 223/255, alpha: 1)
        case .dusk:
            return UIColor(red: 125/255, green: 175/255, blue: 222/255, alpha: 1)
        case .night:
            return UIColor(red: 81/255, green: 103/255, blue: 160/255, alpha: 1)
        }
    }
}

// MARK: Road

enum Road: String, TripConditionable, ChartSettable {
    case localStreet = "Local Street"
    case mainRoad = "Main Road"
    case innerCity = "Inner City"
    case freeway = "Freeway"
    case ruralRoad = "Rural Road"
    case gravel = "Gravel"
    
    static let all = [localStreet, mainRoad, innerCity, freeway, ruralRoad, gravel]
    
    static var sealed: [Road] {
        return [localStreet, mainRoad, innerCity, freeway, ruralRoad]
    }
    
    static var unsealed: [Road] {
        return [gravel]
    }    
    
    var color: UIColor {
        switch self {
        case .localStreet:
            return UIColor(red: 245/255, green: 147/255, blue: 146/255, alpha: 1)
        case .mainRoad:
            return UIColor(red: 178/255, green: 134/255, blue: 165/255, alpha: 1)
        case .innerCity:
            return UIColor(red: 168/255, green: 220/255, blue: 223/255, alpha: 1)
        case .freeway:
            return UIColor(red: 97/255, green: 194/255, blue: 155/255, alpha: 1)
        case .ruralRoad:
            return UIColor(red: 121/255, green: 196/255, blue: 121/255, alpha: 1)
        case .gravel:
            return UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1)
        }
    }
}
