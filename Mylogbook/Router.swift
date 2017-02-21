
import Alamofire

// MARK: Routing

protocol Routing: URLConvertible, URLRequestConvertible {
    var base: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

// MARK: URL Convertible

extension Routing {
    func asURL() throws -> URL {
        let endPoint = "\(base)/\(path)"
        
        return try endPoint.asURL()
    }
}

// MARK: URL Request Convertible

extension Routing {
    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }
}
