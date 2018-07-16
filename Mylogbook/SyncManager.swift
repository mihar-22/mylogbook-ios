
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

    private var lastSyncedAt: Date {
        get {
            return Cache.shared.lastSyncedAt
        }
        
        set(date) {
            Cache.shared.lastSyncedAt = date
        }
    }
    
    private var isSyncPrepared: Bool {
        get {
            return Cache.shared.isSyncPrepared
        }
        
        set(isPrepared) {
            Cache.shared.isSyncPrepared = isPrepared
        }
    }
    
    private var timeSinceLastSync: TimeInterval {
        return Date().timeIntervalSince(lastSyncedAt)
    }

    // MARK: Start
    
    func start() {
        guard network.isReachable else { return }

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
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
            SyncStore<Trip>.import(from: tripRoute) { _ in
                self.isSyncPrepared = true
                
                self.syncComplete()
            }
        }
    }
    
    // MARK: Sync
    
    private func sync() {
        guard network.isReachableOnEthernetOrWiFi || (timeSinceLastSync > 1_800) else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            return
        }
        
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
        let transaction = Store.shared.stack.beginUnsafe()
        
        let trips = transaction.fetchAll(From<Trip>(),
                                         Where<Trip>("id", isEqualTo: 0))!
        
        for trip in trips {
            let route = ResourceRoute<Trip>.store(trip)
            
            group.enter()
            
            Session.shared.requestJSON(route) { response in
                guard let id = response.data?["id"].int64 else { return }
                
                SyncStore<Trip>.set(trip, id: id) { group.leave() }
            }
        }
        
        group.notify(queue: self.queue) { self.syncComplete() }
    }
    
    private func syncComplete() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            self.lastSyncedAt = Date()
            
            Cache.shared.save()

            NotificationCenter.default.post(name: Notification.syncComplete.name, object: nil)
        }
    }
}
