
import Alamofire
import SwiftyJSON

// MARK: API Response

struct ApiResponse<Data> {
    let statusCode: Int
    let message: String
    let data: JSON?
    let errors: [String: String]?
}

// MARK: Session

class Session {
    static let shared: Session = Session()
    
    private let queue = DispatchQueue(label: "com.mylogbook.response",
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
            guard response.result.isSuccess else { return }
            
            guard let value = response.result.value else { return }
            
            let json = JSON(value)
            
            let statusCode = response.response!.statusCode
            
            let message = json["message"].string
            
            let data = json["data"]
            
            let errors = json["errors"].dictionaryObject as? [String: String]
            
            let apiResponse = ApiResponse<Data>(statusCode: statusCode,
                                                message: message!,
                                                data: data,
                                                errors: errors)
            
            self.queue.async { completion(apiResponse) }
        }
    }
    
    func requestCollection(_ route: Routing, completion: @escaping ([JSON]) -> Void) {
        let serializer = DataRequest.jsonResponseSerializer()
        
        manager.request(route).response(queue: queue, responseSerializer: serializer) { response in
            guard response.result.isSuccess else { return }
            
            guard let value = response.result.value else { return }
            
            let json = JSON(value)
            
            self.queue.async { completion(json["data"].arrayValue) }
        }
    }
}
