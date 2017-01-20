
import Alamofire

// MARK: Supervisor Route

enum SupervisorRoute {
    case index
    case store(Supervisor)
    case update(Supervisor)
    case destroy(Supervisor)
}

// MARK: Routable

extension SupervisorRoute: Routable {
    static let resource = "supervisors"
    
    var path: String {
        switch self {
        case .index, .store:
            return ""
        case .update(let supervisor), .destroy(let supervisor):
            return "\(supervisor.id!)"
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
        case .store(let supervisor), .update(let supervisor):
            return supervisor.toJSON()
        }
    }
}

