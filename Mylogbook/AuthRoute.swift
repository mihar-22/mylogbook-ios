
import Alamofire

// MARK: Auth Route

enum AuthRoute {
    case register(name: String, email: String, password: String)
    case login(email: String, password: String)
    case logout
    case forgot(email: String)
}

// MARK: Routing

extension AuthRoute: Routing {
    var base: String {
        return "\(Env.MLB_API_BASE)/auth"
    }
    
    var path: String {
        switch self {
        case .register:
            return "register"
        case .login:
            return "login"
        case .logout:
            return "logout"
        case .forgot:
            return "forgot"
        }        
    }
    
    var method: HTTPMethod {
        switch self {
        case .register, .login, .forgot:
            return .post
        case .logout:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .register(name, email, password):
            return ["name": name, "email": email, "password": password]
        case let .login(email, password):
            return ["email": email, "password": password]
        case .logout:
            return nil
        case let .forgot(email):
            return ["email": email]
        }
    }
}

