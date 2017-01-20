
import Alamofire

// MARK: Routable

protocol Routable: URLConvertible, URLRequestConvertible {
    static var resource: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

// MARK: URL Convertible

extension Routable {
    func asURL() throws -> URL {
        let endPoint = "\(Env.MLB_API_BASE)/\(Self.resource)/\(self.path)"
        
        return try endPoint.asURL()
    }
}

// MARK: URL Request Convertible

extension Routable {
    func asURLRequest() throws -> URLRequest {
        let url = try asURL()
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }
}
