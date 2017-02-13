
import CoreData
import ObjectMapper

// MARK: Supervisor

class Supervisor: NSManagedObject, Resourceable, SoftDeletable, Syncable {
    static let resource = "supervisors"

    var createdAt: Date?

    var fullName: String { return "\(firstName!) \(lastName!)" }
    
    // MARK: Fillable
    
    let fillables = ["firstName", "lastName", "license", "gender"]
    
    // MARK: Initializers
    
    required convenience init?(map: Map) {
        let context = Store.shared.stack.internalContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Supervisor", in: context)
        
        self.init(entity: entity!, insertInto: context)
    }
    
    // MARK: Mappable
    
    func mapping(map: Map) {
        id          <- map["id"]
        firstName   <- map["first_name"]
        lastName    <- map["last_name"]
        license     <- map["license"]
        gender      <- map["gender"]
        createdAt   <- (map["created_at"], DateTransformer())
        updatedAt   <- (map["updated_at"], DateTransformer())
        deletedAt   <- (map["deleted_at"], DateTransformer())
    }
}

// MARK: Equatable

extension Supervisor {
    static func == (lhs: Supervisor, rhs: Supervisor) -> Bool {
        return lhs.id == rhs.id                 &&
               lhs.firstName == rhs.firstName   &&
               lhs.lastName == rhs.lastName     &&
               lhs.license == rhs.license       &&
               lhs.gender == rhs.gender
    }
}

// MARK: Core Data Properties

extension Supervisor {
 
    @NSManaged public var id: Int
    @NSManaged public var firstName: String?
    @NSManaged public var gender: String?
    @NSManaged public var lastName: String?
    @NSManaged public var license: String?
    @NSManaged public var trips: NSSet?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}
