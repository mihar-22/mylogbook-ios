
import Alamofire
import ObjectMapper

// MARK: Resourceable

protocol Resourceable: Mappable {
    static var resource: String { get }
    
    var id: Int { get set }
}

// MARK: Resource Route

enum ResourceRoute<Model: Resourceable> {
    case index
    case sync(since: Date)
    case store(Model)
    case update(Model)
    case destroy(Model)
}

// MARK: Routing

extension ResourceRoute: Routing {
    static var resource: String { return Model.resource }
    
    var path: String {
        switch self {
        case .index, .store:
            return ""
        case .sync(let since):
            return since.iso8601
        case .update(let model):
            return "\(model.id)"
        case .destroy(let model):
            return "\(model.id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .index, .sync:
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
        case .index, .destroy, .sync:
            return nil
        case .store(let model):
            return model.toJSON()
        case .update(let model):
            return model.toJSON()
        }
    }
}
