
import ObjectMapper

// MARK: Car

class Car: Resourceable {
    static let resource = "cars"
    
    var id: Int?
    var make: String?
    var model: String?
    var registration: String?
    var type: String?
    
    var name: String { return "\(make!) \(model!)" }
    
    required init?(map: Map) {}
    
    init(registration: String, make: String, model: String, type: String) {
        self.registration = registration
        self.make = make
        self.model = model
        self.type = type
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        make            <- map["make"]
        model           <- map["model"]
        registration    <- map["registration"]
        type            <- map["type"]
    }
}
