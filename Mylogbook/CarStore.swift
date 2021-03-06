
import CoreStore

// MARK: Car Store

class CarStore: SoftDeletingStore {
    static func add(_ car: Car?,
                    registration: String,
                    name: String,
                    type: String) {
        
        try! Store.shared.stack.perform(synchronous: { (transaction) in
            let car: Car = (car != nil) ? transaction.edit(car)! : transaction.create(Into<Car>())
            
            car.registration = registration
            car.name = name
            car.type = type
            
            car.updatedAt = Date()
        }, waitForAllObservers: true)
    }
}
