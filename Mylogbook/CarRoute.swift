
import Alamofire

// MARK: Car Route

enum CarRoute {
    case index
    case store(Car)
    case update(Car)
    case destroy(Car)
}

// MARK: Routable

extension CarRoute: Routable {
    static let resource = "cars"
    
    var path: String {
        switch self {
        case .index, .store:
            return ""
        case .update(let car), .destroy(let car):
            return "\(car.id!)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .index:
            return .get
        case .store:
            return .post
        case .update:
            return .put
        case .destroy:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .index, .destroy:
            return nil
        case .store(let car), .update(let car):
            return car.toJSON()
        }
    }
}

