
import CoreStore

// MARK: Supervisor Store

class SupervisorStore: SoftDeletingStore {
    static func add(_ supervisor: Supervisor?,
                    firstName: String,
                    lastName: String,
                    gender: String,
                    isAccredited: Bool) {
        
        Store.shared.stack.beginSynchronous { transaction in
            let supervisor: Supervisor = (supervisor != nil) ? transaction.edit(supervisor)! :
                                                               transaction.create(Into<Supervisor>())
            
            supervisor.firstName = firstName
            supervisor.lastName = lastName
            supervisor.gender = gender
            supervisor.isAccredited = isAccredited
            
            supervisor.updatedAt = Date()
            
            _ = transaction.commitAndWait()
        }
        
    }
}
