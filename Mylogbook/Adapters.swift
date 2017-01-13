
import Alamofire

// MARK: API Token Adapter

class ApiTokenAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if (urlRequest.url?.absoluteString.hasPrefix(Env.MLB_API_BASE))! {
            if let apiToken = Keychain.shared.apiToken {
                urlRequest.setValue("Bearer \(apiToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return urlRequest
    }
}
