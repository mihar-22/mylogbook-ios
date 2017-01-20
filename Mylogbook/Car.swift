
import ObjectMapper

// MARK: Car

class Car: Mappable {
    var id: Int?
    var make: String?
    var model: String?
    var registration: String?
    var type: String?
    
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
