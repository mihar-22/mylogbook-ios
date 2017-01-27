
import ObjectMapper

// MARK: Supervisor

class Supervisor: Resourceable {
    static let resource = "supervisors"
    
    var id: Int?
    var firstName: String?
    var lastName: String?
    var license: String?
    var gender: String?
    
    var fullName: String { return "\(firstName!) \(lastName!)" }
    
    required init?(map: Map) {}
    
    init(firstName: String, lastName: String, license: String, gender: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.license = license
        self.gender = gender
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        firstName   <- map["first_name"]
        lastName    <- map["last_name"]
        license     <- map["license"]
        gender      <- map["gender"]
    }
}
