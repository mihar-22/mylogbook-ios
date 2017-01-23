
import Alamofire
import ObjectMapper

// MARK: Resource Route

enum ResourceRoute<Model: Resourceable> {
    case index
    case store(Model)
    case update(Model)
    case destroy(Model)
}

extension ResourceRoute: Routable {
    static var resource: String { return Model.resource }
    
    var path: String {
        switch self {
        case .index, .store:
            return ""
        case .update(let model):
            return "\(model.id!)"
        case .destroy(let model):
            return "\(model.id!)"
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
        case .store(let model):
            return model.toJSON()
        case .update(let model):
            return model.toJSON()
        }
    }
}
