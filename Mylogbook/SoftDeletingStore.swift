
import CoreStore
import Foundation

// MARK: Soft Deletable

protocol SoftDeletable: class {
    var deletedAt: Date? { get set }
}

// MARK: Soft Deleting Store

protocol SoftDeletingStore {
    static func delete<Model: NSManagedObject>(_ model: Model) where Model: SoftDeletable
}

extension SoftDeletingStore {
    static func delete<Model: NSManagedObject>(_ model: Model) where Model: SoftDeletable {
        Store.shared.stack.beginSynchronous { (transaction) in
            let model = transaction.edit(model)!
            
            model.deletedAt = Date()
                        
            _ = transaction.commitAndWait()
        }
    }
}
