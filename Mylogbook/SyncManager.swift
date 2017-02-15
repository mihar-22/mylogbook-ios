
import Alamofire
import CoreStore
import Dispatch
import Foundation
import SwiftyJSON

// MARK: Sync Manager

class SyncManager {
    private let queue = DispatchQueue(label: "com.mylogbook.sync-manager",
                                      qos: .background,
                                      attributes: [.concurrent])
    
    private let network = NetworkReachabilityManager()!
    
    private var isSyncPrepared: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isSyncPrepared")
        }
        
        set(isSyncPrepared) {
            UserDefaults.standard.set(isSyncPrepared, forKey: "isSyncPrepared")
            
            UserDefaults.standard.synchronize()
        }
    }
    
    private var lastSyncedAt: Date {
        get {
            return UserDefaults.standard.object(forKey: "lastSyncedAt") as! Date
        }
        
        set(lastSyncedAt) {
            UserDefaults.standard.set(lastSyncedAt, forKey: "lastSyncedAt")
        }
    }
    
    private var timeSinceLastSync: TimeInterval {
        return Date().timeIntervalSince(lastSyncedAt)
    }

    // MARK: Start
    
    func start() {
        guard network.isReachable else { return }
        
        queue.async {
            if !self.isSyncPrepared { self.prepare() }
            else { self.sync() }
        }
    }
    
    // MARK: Prepare
    
    private func prepare() {
        let group = DispatchGroup()
        
        // Cars
        let carRoute = ResourceRoute<Car>.index
        
        group.enter()
        
        SyncStore<Car>.import(from: carRoute) { _ in group.leave() }
        
        // Supervisors
        let supervisorRoute = ResourceRoute<Supervisor>.index
        
        group.enter()
        
        SyncStore<Supervisor>.import(from: supervisorRoute) { _ in group.leave() }
        
        // Trips
        let tripRoute = ResourceRoute<Trip>.index
        
        group.notify(queue: queue) {
            SyncStore<Trip>.import(from: tripRoute) { _ in self.preparationComplete() }
        }
    }
    
    private func preparationComplete() {
        self.isSyncPrepared = true
        
        self.lastSyncedAt = Date()
    }
    
    // MARK: Sync
    
    private func sync() {
        guard network.isReachableOnEthernetOrWiFi ||
              (timeSinceLastSync > (mins: 30) * (secsPerMin: 60)) else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        Sync<Car>.init(since: lastSyncedAt).sync { group.leave() }
        
        group.enter()
        
        Sync<Supervisor>.init(since: lastSyncedAt).sync { group.leave() }
        
        group.notify(queue: queue) { self.syncTrips() }
    }
    
    private func syncTrips() {
        let group = DispatchGroup()
        
        // Pull
        let route = ResourceRoute<Trip>.sync(since: self.lastSyncedAt)
        
        group.enter()
        
        SyncStore<Trip>.import(from: route) { _ in  group.leave() }
        
        // Push
        let trips = Store.shared.stack.beginUnsafe().fetchAll(From<Trip>(),
                                                              Where("id = 0"))!
        
        for trip in trips {
            let route = ResourceRoute<Trip>.store(trip)
            
            group.enter()
            
            Session.shared.requestJSON(route) { response in
                guard let id = response.data?["id"].int else { return }
                
                SyncStore<Trip>.set(trip, id: id) { group.leave() }
            }
        }
        
        group.notify(queue: self.queue) { self.lastSyncedAt = Date() }
    }
}
