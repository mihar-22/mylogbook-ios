
import CoreStore

// MARK: Fillable

protocol Fillable {
    var fillables: [String] { get }
    
    func relationships() -> [String: Int]?
}

extension Fillable {
    func relationships() -> [String: Int]? { return nil }
}

// MARK: Syncable

protocol Syncable: Fillable {
    var id: Int { get set }
    
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
    var deletedAt: Date? { get set }
}

// MARK: Sync Store

class SyncStore {
    static func add<Model: NSManagedObject>(fromNetwork models: [Model],
                    completion: @escaping () -> Void) where Model: Syncable {
        
        Store.shared.stack.beginAsynchronous { transaction in
            for newModel in models {
                var model = transaction.create(Into(Model.self))
                
                model.id = newModel.id
                
                for key in model.fillables {
                    let value = newModel.value(forKey: key)
                    
                    model.setValue(value, forKey: key)
                }
                
                if let relationships = model.relationships() {
                    for (key, id) in relationships {
                        let relationship = Store.shared.stack.fetchOne(From(Model.self),
                                                                       Where("id = \(id)"))
                        
                        model.setValue(relationship, forKey: key)
                    }
                }
                
                model.updatedAt = newModel.updatedAt
                model.deletedAt = newModel.deletedAt
            }
            
            transaction.commit() { _ in completion() }
        }
        
    }
    
    static func set<Model: NSManagedObject>(_ model: Model,
                    id: Int,
                    completion: @escaping () -> Void) where Model: Syncable {
        
        Store.shared.stack.beginAsynchronous { transaction in
            var model = transaction.edit(model)!
            
            model.id = id
            
            transaction.commit() { _ in completion() }
        }
        
    }
    
    static func update<Model: NSManagedObject>(_ localModel: Model,
                       _ networkModel: Model,
                       completion: @escaping () -> Void) where Model: Syncable {
        
        Store.shared.stack.beginAsynchronous { transaction in
            var model = transaction.edit(localModel)!
            
            for key in model.fillables() {
                let value = networkModel.value(forKey: key)
                
                model.setValue(value, forKey: key)
            }
            
            model.updatedAt = Date()
            
            transaction.commit() { _ in completion() }
        }
        
    }
    
    static func delete<Model: NSManagedObject>(_ models: [Model],
                       completion: @escaping () -> Void) where Model: Syncable {
        
        Store.shared.stack.beginAsynchronous { transaction in
            for model in models {
                var model = transaction.edit(model)!
                
                model.deletedAt = Date()
            }
            
            transaction.commit() { _ in completion() }
        }
        
    }
}
