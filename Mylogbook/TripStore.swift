
import CoreStore

// MARK: Trip Store

class TripStore {
    static func add(_ newTrip: Trip) {
        Store.shared.stack.beginSynchronous { transaction in
            let trip: Trip = transaction.create(Into<Trip>())
            
            trip.car = transaction.edit(newTrip.car)
            trip.supervisor = transaction.edit(newTrip.supervisor)
            
            trip.startedAt = newTrip.startedAt
            trip.endedAt = newTrip.endedAt
            trip.odometer = newTrip.odometer
            trip.distance = newTrip.distance

            trip.clear = newTrip.clear
            trip.rain = newTrip.rain
            trip.thunder = newTrip.thunder
            
            trip.light = newTrip.light
            trip.moderate = newTrip.moderate
            trip.heavy = newTrip.heavy
            
            trip.localStreet = newTrip.localStreet
            trip.mainRoad = newTrip.mainRoad
            trip.innerCity = newTrip.innerCity
            trip.freeway = newTrip.freeway
            trip.ruralHighway = newTrip.ruralHighway
            trip.gravel = newTrip.gravel
            
            _ = transaction.commitAndWait()
        }
    }
}
