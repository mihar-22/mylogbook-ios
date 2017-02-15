
import CoreStore
import SwiftyJSON

// MARK: Importable

protocol Importable: ImportableUniqueObject {}

extension Importable where Self: NSManagedObject, Self: Resourceable {
    static func uniqueID(from source: JSON,
                         in transaction: BaseDataTransaction)
                         throws -> NSNumber? {
        
        return source["id"].number
    }
}

extension Importable where Self: NSManagedObject, Self: Resourceable, Self: Syncable {
    static func shouldUpdate(from source: JSON, in transaction: BaseDataTransaction) -> Bool {
        let id = source["id"].int!
        
        guard let model = transaction.fetchOne(From<Self>(), Where("id = \(id)")) else { return true }
        
        return model.updatedAt! < source["updated_at"].stringValue.dateFromISO8601! ||
               (model.deletedAt == nil && source["deleted_at"].string != nil)
    }
}

// MARK: Sync Store

class SyncStore<Model: NSManagedObject> where Model: Importable,
                                              Model: Resourceable,
                                              Model.ImportSource == JSON,
                                              Model.UniqueIDType: Hashable {
 
    static func `import`(from route: Routing, completion: @escaping ([Model]) -> Void){
        let route = ResourceRoute<Model>.index
        
        Session.shared.requestCollection(route) { collection in
            Store.shared.stack.beginAsynchronous { transaction in
                let imports = try! transaction.importUniqueObjects(Into<Model>(),
                                                                   sourceArray: collection)
                
                transaction.commit() { _ in completion(imports) }
            }
        }
    }
    
    static func set(_ model: Model, id: Int, completion: @escaping () -> Void) {
        Store.shared.stack.beginAsynchronous { transaction in
            var model = transaction.edit(model)!
            
            model.id = id
            
            transaction.commit() { _ in completion() }
        }
    }
}
