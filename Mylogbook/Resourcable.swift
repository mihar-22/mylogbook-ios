
import ObjectMapper

// MARK: Resourceable

protocol Resourceable: Mappable {
    static var resource: String { get }
    
    var id: Int? { get }
}
