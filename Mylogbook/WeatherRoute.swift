
import Alamofire
import CoreLocation

// MARK: Weather Route

enum WeatherRoute {
    case geographic(CLLocation)
}

// MARK: Routing

extension WeatherRoute: Routing {
    private static let apiKey = "f8e21e4dce522c92ece4b6df4b40472a"

    var base: String {
        return "http://api.openweathermap.org/data/2.5"
    }
    
    var path: String {
        switch self {
        case .geographic(let location):
            let lat = location.coordinate.latitude

            let long = location.coordinate.longitude
            
            return "weather?lat=\(lat)&lon=\(long)&appid=\(WeatherRoute.apiKey)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .geographic:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .geographic:
            return nil
        }
    }
}
