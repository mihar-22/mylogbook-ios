
import Alamofire
import CoreStore
import Dispatch
import Foundation

// MARK: Sync Manager

class SyncManager {
    private let queue = DispatchQueue(label: "com.mylogbook.sync-manager",
                                      qos: .background,
                                      attributes: [.concurrent])
    
    private lazy var group = DispatchGroup()
    
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
        
        if !isSyncPrepared { prepare() }
        else { sync() }
    }
    
    // MARK: Prepare
    
    private func prepare() {
        queue.async {
            self.prepareCars()
            
            self.prepareSupervisors()
            
            self.prepareTrips()
        }
    }
    
    private func prepareCars() {
        let route = ResourceRoute<Car>.index
        
        group.enter()
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Car]>) in
            guard let cars = response.data else { return }
            
            SyncStore.add(fromNetwork: cars) { _  in self.group.leave() }
        }
    }
    
    private func prepareSupervisors() {
        let route = ResourceRoute<Supervisor>.index
        
        group.enter()
        
        Session.shared.requestCollection(route) { (response: ApiResponse<[Supervisor]>) in
            guard let supervisors = response.data else { return }
            
            SyncStore.add(fromNetwork: supervisors) { _ in self.group.leave() }
        }
    }
    
    private func prepareTrips() {
        let route = ResourceRoute<Trip>.index
        
        group.notify(queue: queue) {
            Session.shared.requestCollection(route) { (response: ApiResponse<[Trip]>) in
                guard let trips = response.data else { return }
                
                SyncStore.add(fromNetwork: trips) { self.preparationComplete() }
            }
        }
    }
    
    private func preparationComplete() {
        self.isSyncPrepared = true
        
        self.lastSyncedAt = Date()
    }
    
    // MARK: Sync
    
    private func sync() {
        guard network.isReachableOnEthernetOrWiFi || (timeSinceLastSync > 300) else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        
        Sync<Car>.init(since: lastSyncedAt).sync { group.leave() }
        
        group.enter()
        
        Sync<Supervisor>.init(since: lastSyncedAt).sync { group.leave() }
        
        group.notify(queue: queue) {
            Sync<Trip>.init(since: self.lastSyncedAt).sync { self.lastSyncedAt = Date() }
        }
    }
}
