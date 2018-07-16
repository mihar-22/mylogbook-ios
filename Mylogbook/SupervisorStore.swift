
import CoreStore

// MARK: Supervisor Store

class SupervisorStore: SoftDeletingStore {
    static func add(_ supervisor: Supervisor?,
                    name: String,
                    gender: String,
                    isAccredited: Bool) {
        
        try! Store.shared.stack.perform(synchronous: { (transaction) in
            let supervisor: Supervisor = (supervisor != nil) ? transaction.edit(supervisor)! :
                                                               transaction.create(Into<Supervisor>())
            
            supervisor.name = name
            supervisor.gender = gender
            supervisor.isAccredited = isAccredited
            
            supervisor.updatedAt = Date()
        }, waitForAllObservers: true)
    }
}
