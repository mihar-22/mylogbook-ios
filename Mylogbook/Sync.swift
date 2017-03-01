
import CoreStore
import Dispatch
import Foundation
import SwiftyJSON

// MARK: Syncable

protocol Syncable {
    var id: Int { get set }
    
    var updatedAt: Date { get set }
    var deletedAt: Date? { get set }
}

// MARK: Sync

class Sync<Model: NSManagedObject> where Model: Resourceable,
                                         Model: Syncable,
                                         Model: Importable,
                                         Model.UniqueIDType: Hashable,
                                         Model.ImportSource == JSON {
    
    private var queue = DispatchQueue(label: "com.mylogbook.sync",
                                      qos: .background,
                                      attributes: [.concurrent])
    
    private var lastSyncedAt: Date
    
    private var models = [Model]()
    
    // MARK: Initializers
    
    init(since: Date) {
        lastSyncedAt = since
    }
    
    // MARK: Sync
    
    func sync(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.models = Store.shared.stack.fetchAll(From(Model.self))!
            
            self.queue.async {
                let group = DispatchGroup()
                
                let route = ResourceRoute<Model>.sync(since: self.lastSyncedAt)
                
                group.enter()
                
                SyncStore<Model>.import(from: route) { _ in  group.leave() }
            
                group.enter()
                
                self.push { group.leave() }
                
                group.notify(queue: self.queue) { completion() }
            }
        }
    }
    
    // MARK: Push
    
    private func push(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        
        pushInsertions { group.leave() }
        
        group.enter()
        
        pushUpdates { group.leave() }
        
        group.notify(queue: queue) {
            self.pushDeletions { completion() }
        }
    }
    
    private func pushInsertions(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for model in models.filter({ $0.id == 0 }) {
            let route = ResourceRoute<Model>.store(model)
            
            group.enter()
            
            Session.shared.requestJSON(route) { response in
                guard let id = response.data?["id"].int else { return }
                
                SyncStore<Model>.set(model, id: id) { group.leave() }
            }
        }
        
        group.notify(queue: queue) { completion() }
    }
    
    private func pushUpdates(completion: @escaping() -> Void) {
        let group = DispatchGroup()

        for model in models.filter({ $0.updatedAt > lastSyncedAt }) {
            let route = ResourceRoute<Model>.update(model)
            
            group.enter()
            
            Session.shared.requestJSON(route) { _ in group.leave() }
        }
        
        group.notify(queue: queue) { completion() }
    }
    
    private func pushDeletions(completion: @escaping() -> Void) {
        let group = DispatchGroup()
        
        let deletes = models.filter({ $0.deletedAt != nil })
                            .filter({ $0.deletedAt! > lastSyncedAt })
        
        for model in deletes {
            let route = ResourceRoute<Model>.destroy(model)
            
            group.enter()
            
            Session.shared.requestJSON(route) { _ in group.leave() }
        }
        
        group.notify(queue: queue) { completion() }
    }
}
