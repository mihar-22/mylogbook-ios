
import Alamofire

typealias Message = String
typealias Data = [String: Any]
typealias Error = [String: String]

// MARK: ApiResponse

struct ApiResponse {
    let statusCode: Int
    let message: Message
    let data: Data?
    let errors: Error?
}

// MARK: Session

class Session {
    static let shared: Session = Session()
    
    private let manager: SessionManager
    
    private init() {
        manager = SessionManager()
        
        manager.adapter = ApiTokenAdapter()
    }
    
    func requestJSON(_ route: Routable, completion: @escaping (ApiResponse) -> Void) {
        manager.request(route).responseJSON { response in
            guard let json = response.result.value as? [String: Any] else { return }
            
            guard let statusCode = response.response?.statusCode else { return }
            
            let message = json["message"] as! Message
            
            let data = json["data"] as? Data
            
            let errors = json["errors"] as? Error
            
            let _response = ApiResponse(statusCode: statusCode, message: message, data: data, errors: errors)
            
            completion(_response)
        }
    }
}
