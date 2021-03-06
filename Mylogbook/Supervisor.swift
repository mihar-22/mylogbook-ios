
import CoreStore
import SwiftyJSON

// MARK: Supervisor

class Supervisor: NSManagedObject, SoftDeletable, Syncable {    
    var uniqueIDValue: NSNumber {
        get { return NSNumber(integerLiteral: Int(self.id)) }
        
        set(id) { self.id = Int64(truncating: id) }
    }
}

// MARK: Image

extension Supervisor {
    enum ImageSize: String {
        case regular = ""
        case display = "-display"
    }
    
    func image(ofSize size: ImageSize) -> UIImage {
        let gender = (self.gender == "M") ? "male" : "female"
        
        var name = "supervisor-\(gender)"
        
        if isAccredited { name += "-certified" }
        
        name += size.rawValue
        
        return UIImage(named: name)!
    }
}

// MARK: Importable

extension Supervisor: Importable {
    typealias ImportSource = JSON
    
    static let uniqueIDKeyPath = "id"

    func update(from source: JSON, in transaction: BaseDataTransaction) throws  {
        name = source["name"].string!
        gender = source["gender"].string!
        isAccredited = source["is_accredited"].bool!
        
        updatedAt = source["updated_at"].string!.utc(format: .dateTime)
        deletedAt = source["deleted_at"].string?.utc(format: .dateTime)
    }
}

// MARK: Resourcable

extension Supervisor: Resourceable {
    static let resource = "supervisors"
    
    func toJSON() -> [String: Any] {
        return [
            "name": name,
            "gender": gender,
            "is_accredited": isAccredited ? 1 : 0
        ]
    }
}

// MARK: Core Data Properties

extension Supervisor {
    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var gender: String
    @NSManaged public var trips: NSSet?
    @NSManaged public var isAccredited: Bool
    @NSManaged public var updatedAt: Date
    @NSManaged public var deletedAt: Date?
}
