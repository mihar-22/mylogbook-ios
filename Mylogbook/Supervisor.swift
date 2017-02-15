
import CoreStore
import SwiftyJSON

// MARK: Supervisor

class Supervisor: NSManagedObject, SoftDeletable, Syncable {
    var fullName: String { return "\(firstName!) \(lastName!)" }
    
    var uniqueIDValue: Int {
        get { return self.id }
        
        set(id) { self.id = id }
    }
}

// MARK: Importable

extension Supervisor: Importable {
    typealias ImportSource = JSON
    
    static let uniqueIDKeyPath = "id"

    func update(from source: JSON, in transaction: BaseDataTransaction) throws  {
        firstName = source["first_name"].string
        lastName = source["last_name"].string
        license = source["license"].string
        gender = source["gender"].string
        
        updatedAt = source["updated_at"].string?.dateFromISO8601
        deletedAt = source["deleted_at"].string?.dateFromISO8601
    }
}

// MARK: Resourcable

extension Supervisor: Resourceable {
    static let resource = "supervisors"
    
    func toJSON() -> [String: Any] {
        return [
            "first_name": firstName!,
            "last_name": lastName!,
            "license": license!,
            "gender": gender!
        ]
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
