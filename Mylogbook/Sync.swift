
import CoreStore
import Dispatch
import Foundation

// MARK: Sync

class Sync<Model: NSManagedObject> where Model: Resourceable, Model: Syncable, Model: Equatable {
    
    private var queue = DispatchQueue(label: "com.mylogbook.sync",
                                      qos: .background,
                                      attributes: [.concurrent])
    
    private var lastSyncedAt: Date
    
    private var localModels = [Int: Model]()
    
    private var networkModels = [Int: Model]()
    
    // MARK: Initializers
    
    init(since: Date) {
        lastSyncedAt = since
    }
    
    // MARK: Sync
    
    func sync(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        // Local Models
        
        group.enter()
        
        DispatchQueue.main.async {
            let localModels = Store.shared.stack.fetchAll(From(Model.self))!
            
            var _id = -1
            
            localModels.forEach {
                if $0.id == 0 {
                    self.localModels[_id] = $0
                    
                    _id = _id - 1
                } else { self.localModels[$0.id] = $0 }
            }
            
            group.leave()
        }
        
        // Network Models
        
        group.enter()
        
        let route = ResourceRoute<Model>.sync(since: lastSyncedAt)
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Model]>) in
            let networkModels = response.data
            
            networkModels?.forEach { self.networkModels[$0.id] = $0 }
            
            group.leave()
        }
        
        // Sync Transactions
        
        group.notify(queue: queue) {
            self.insertions() {
                self.updates {
                    self.deletions {
                        completion()
                    }
                }
            }
        }
    }
    
    // MARK: Insertions
    
    private func insertions(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        // MARK: Push
        
        let pushInserts = localModels.filter({ $0.key < 0 })
                                     .map({ $0.value })
        
        if pushInserts.count > 0 {
            for model in pushInserts {
                let route = ResourceRoute<Model>.store(model)
                
                group.enter()
                
                Session.shared.requestJSON(route) { response in
                    guard let id = response.data?["id"] as? Int else { return }
                    
                    SyncStore.set(model, id: id) { group.leave() }
                }
            }
        }
        
        // MARK: Pull
        
        let pullInserts = networkModels.filter({ $0.value.createdAt! > lastSyncedAt })
                                       .filter({ localModels[$0.key] == nil })
                                       .map({ $0.value })
        
        if pullInserts.count > 0 {
            group.enter()
            
            SyncStore.add(fromNetwork: pullInserts) { group.leave() }
        }
        
        group.notify(queue: queue) { completion() }
    }
    
    // MARK: Updates
    
    private func updates(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        func push(_ model: Model) {
            let route = ResourceRoute<Model>.update(model)
                
            group.enter()
            
            Session.shared.requestJSON(route) { _ in group.leave() }
        }
        
        func pull(_ localModel: Model, _ networkModel: Model) {
            group.enter()
            
            SyncStore.update(localModel, networkModel) { group.leave() }
        }
        
        for (id, localModel) in localModels {
            if let networkModel = networkModels[id] {
                
                if localModel == networkModel {
                    continue
                } else if localModel.updatedAt! > networkModel.updatedAt! {
                    push(localModel)
                } else {
                    pull(localModel, networkModel)
                }
                
            } else if localModel.updatedAt! > lastSyncedAt {
                push(localModel)
            }
        }
        
        group.notify(queue: queue) { completion() }
    }
    
    // MARK: Deletions
    
    private func deletions(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        // MARK: Push
        
        let pushDeletes = localModels.filter({ $0.value.deletedAt != nil })
                                     .filter({ $0.value.deletedAt! > lastSyncedAt })
                                     .filter({ networkModels[$0.key]?.deletedAt == nil })
                                     .map({ $0.value })
        
        if pushDeletes.count > 0 {
            for model in pushDeletes {
                let route = ResourceRoute<Model>.destroy(model)
                
                group.enter()
                
                Session.shared.requestJSON(route) { _ in group.leave() }
            }
        }
        
        // MARK: Pull
        
        let pullDeletes = networkModels.filter { $0.value.deletedAt != nil }
                                       .filter({ $0.value.deletedAt! > lastSyncedAt })
                                       .filter({ localModels[$0.key]?.deletedAt == nil })
                                       .map({ localModels[$0.key]! })
        
        if pullDeletes.count > 0 {
            group.enter()
            
            SyncStore.delete(pullDeletes) { group.leave() }
        }
        
        group.notify(queue: queue) { completion() }
    }
}
