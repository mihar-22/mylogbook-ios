
import CoreStore

// MARK: Car Store

class CarStore: SoftDeletingStore {
    static func add(_ car: Car?,
                    registration: String,
                    make: String,
                    model: String,
                    type: String) {
        
        Store.shared.stack.beginSynchronous { transaction in
            let car: Car = (car != nil) ? transaction.edit(car)! : transaction.create(Into<Car>())
            
            car.registration = registration
            car.make = make
            car.model = model
            car.type = type
            
            car.updatedAt = Date()
            
            _ = transaction.commitAndWait()
        }
    }
}
