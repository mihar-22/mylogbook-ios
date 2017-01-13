
import Alamofire

// MARK: Routable

protocol Routable: URLConvertible, URLRequestConvertible {
    static var resource: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

extension Routable {
    func asURL() throws -> URL {
        let endPoint = "\(Env.MLB_API_BASE)/\(Self.resource)/\(self.path)"
        
        return try endPoint.asURL()
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try self.asURL()
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = self.method.rawValue
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return try URLEncoding.default.encode(urlRequest, with: self.parameters)
    }
}
