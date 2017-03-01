
import CoreStore

// MARK: Supervisor Store

class SupervisorStore: SoftDeletingStore {
    static func add(_ supervisor: Supervisor?,
                    license: String,
                    firstName: String,
                    lastName: String,
                    gender: String) {
        
        Store.shared.stack.beginSynchronous { transaction in
            let supervisor: Supervisor = (supervisor != nil) ? transaction.edit(supervisor)! :
                                                               transaction.create(Into<Supervisor>())
            
            supervisor.license = license
            supervisor.firstName = firstName
            supervisor.lastName = lastName
            supervisor.gender = gender
            
            supervisor.updatedAt = Date()
            
            _ = transaction.commitAndWait()
        }
        
    }
}
