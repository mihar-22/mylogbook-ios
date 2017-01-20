
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

typealias Message = String
typealias Data = [String: Any]
typealias Error = [String: String]

// MARK: API Response

struct ApiResponse<Data> {
    let statusCode: Int
    let message: Message?
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
    
    func requestJSON(_ route: Routable, completion: @escaping (ApiResponse<Data>) -> Void) {
        
        manager.request(route).responseJSON { response in
            guard let apiResponse = self.unpackJSONResponse(response) else { return }
            
            completion(apiResponse)
        }
        
    }
    
    func requestCollection<Model: Mappable>(_ route: Routable, completion: @escaping (ApiResponse<[Model]>) -> Void) {
        
        manager.request(route).responseArray(keyPath: "data") { (response: DataResponse<[Model]>) in
            guard let apiResponse: ApiResponse<[Model]> = self.unpackArrayResponse(response) else { return }

            completion(apiResponse)
        }
        
    }
    
    private func unpackJSONResponse(_ response: DataResponse<Any>) -> ApiResponse<Data>? {
        guard let json = response.result.value as? [String: Any] else { return nil }
        
        guard let statusCode = response.response?.statusCode else { return nil }
        
        let message = json["message"] as? Message
        
        let data = json["data"] as? Data
        
        let errors = json["errors"] as? Error
        
        return ApiResponse<Data>(statusCode: statusCode, message: message, data: data, errors: errors)
    }
    
    private func unpackArrayResponse<Model: Mappable>(_ response: DataResponse<[Model]>) -> ApiResponse<[Model]>? {
        guard let statusCode = response.response?.statusCode else { return nil }
        
        let collection = response.result.value
        
        return ApiResponse<[Model]>(statusCode: statusCode, message: nil, data: collection, errors: nil)
    }
}
