
import Alamofire

// MARK: Auth Route

enum AuthRoute {
    case register(name: String, email: String, password: String, birthday: String)
    case check
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
        case .check:
            return "check"
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
        case .logout, .check:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case let .register(name, email, password, birthday):
            return ["name": name, "email": email, "password": password, "birthday": birthday]
        case let .login(email, password):
            return ["email": email, "password": password]
        case .logout, .check:
            return nil
        case let .forgot(email):
            return ["email": email]
        }
    }
}

