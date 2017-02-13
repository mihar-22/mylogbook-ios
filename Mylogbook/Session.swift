
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
    
    private let queue = DispatchQueue(label: "com.mylogbook.response-queue",
                                      qos: .utility,
                                      attributes: [.concurrent])
    
    let manager: SessionManager = {
        let manager = SessionManager()
        
        manager.adapter = ApiTokenAdapter()
        
        return manager
    }()
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Requests
    
    func requestJSON(_ route: Routing, completion: @escaping (ApiResponse<Data>) -> Void) {
        let serializer = DataRequest.jsonResponseSerializer()
        
        manager.request(route).response(queue: queue, responseSerializer: serializer) { response in
            guard let apiResponse = self.unpackJSONResponse(response) else { return }
            
            completion(apiResponse)
        }
    }
    
    func requestCollection<Model: Mappable>(_ route: Routing,
                                            completion: @escaping (ApiResponse<[Model]>) -> Void) {
        
        manager.request(route)
            .responseArray(queue: queue, keyPath: "data", context: nil) { (response: DataResponse<[Model]>) in
            guard let apiResponse: ApiResponse<[Model]> = self.unpackArrayResponse(response) else { return }
            
            completion(apiResponse)
        }
        
    }
    
    // MARK: Unpackers
    
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
