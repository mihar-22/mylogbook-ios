
import CoreStore

// MARK: Trip Store

class TripStore {
    static func add(_ newTrip: Trip) {
        try! Store.shared.stack.perform(synchronous: { (transaction) in
            let trip: Trip = transaction.create(Into<Trip>())
            
            trip.car = transaction.edit(newTrip.car)!
            trip.supervisor = transaction.edit(newTrip.supervisor)!
            
            trip.startedAt = newTrip.startedAt
            trip.endedAt = newTrip.endedAt
            trip.odometer = newTrip.odometer
            trip.distance = newTrip.distance
            
            trip.weather = newTrip.weather
            trip.traffic = newTrip.traffic
            trip.roads = newTrip.roads
            trip.light = newTrip.light
            
            trip.startLatitude = newTrip.startLatitude
            trip.startLongitude = newTrip.startLongitude
            trip.endLatitude = newTrip.endLatitude
            trip.endLongitude = newTrip.endLongitude
            
            trip.startLocation = newTrip.startLocation
            trip.endLocation = newTrip.endLocation
            trip.timeZoneIdentifier = newTrip.timeZoneIdentifier
        }, waitForAllObservers: true)
    }
    
    static func accumulated(_ trips: [Trip]) {
        try! Store.shared.stack.perform(synchronous: { (transaction) in
            for trip in trips {
                let trip = transaction.edit(trip)!

                trip.isAccumulated = true
            }
        }, waitForAllObservers: true)
    }
}
