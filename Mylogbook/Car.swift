
import CoreStore
import SwiftyJSON

// MARK: Car

class Car: NSManagedObject, SoftDeletable, Syncable {
    var name: String { return "\(make) \(model)" }
    
    var uniqueIDValue: Int {
        get { return self.id }
        
        set(id) { self.id = id }
    }
}

// MARK: Importable

extension Car: Importable {
    typealias ImportSource = JSON
    
    static let uniqueIDKeyPath = "id"
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        make = source["make"].string!
        model = source["model"].string!
        registration = source["registration"].string!
        type = source["type"].string!
        
        updatedAt = source["updated_at"].string!.utc(format: .dateTime)
        deletedAt = source["deleted_at"].string?.utc(format: .dateTime)
    }
}

// MARK: Resourcable

extension Car: Resourceable {
    static let resource = "cars"

    func toJSON() -> [String: Any] {
       return [
            "make": make,
            "model": model,
            "registration": registration,
            "type": type
        ]
    }
}

// MARK: Core Data Properties

extension Car {
    @NSManaged public var id: Int
    @NSManaged public var make: String
    @NSManaged public var model: String
    @NSManaged public var registration: String
    @NSManaged public var type: String
    @NSManaged public var trips: NSSet?
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?
}
