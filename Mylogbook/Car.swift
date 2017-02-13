
import CoreData
import ObjectMapper

// MARK: Car

class Car: NSManagedObject, Resourceable, SoftDeletable, Syncable {
    static let resource = "cars"
    
    var createdAt: Date?
    
    var name: String { return "\(make!) \(model!)" }
    
    // MARK: Fillable
    
    let fillables = ["make", "model", "type", "registration"]
    
    // MARK: Initializers
    
    required convenience init?(map: Map) {
        let context = Store.shared.stack.internalContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
        
        self.init(entity: entity!, insertInto: context)
    }
    
    // MARK: Mappable

    func mapping(map: Map) {
        id              <- map["id"]
        make            <- map["make"]
        model           <- map["model"]
        registration    <- map["registration"]
        type            <- map["type"]
        createdAt       <- (map["created_at"], DateTransformer())
        updatedAt       <- (map["updated_at"], DateTransformer())
        deletedAt       <- (map["deleted_at"], DateTransformer())
    }
}

// MARK: Equatable

extension Car {
    static func == (lhs: Car, rhs: Car) -> Bool {
        return lhs.id == rhs.id         &&
               lhs.make == rhs.make     &&
               lhs.model == rhs.model   &&
               lhs.type == rhs.type     &&
               lhs.registration == rhs.registration
    }
}

// MARK: Core Data Properties

extension Car {
    
    @NSManaged public var id: Int
    @NSManaged public var make: String?
    @NSManaged public var model: String?
    @NSManaged public var registration: String?
    @NSManaged public var type: String?
    @NSManaged public var trips: NSSet?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?
}
