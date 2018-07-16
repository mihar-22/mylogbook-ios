
import CoreStore
import CoreLocation
import SwiftyJSON

// MARK: Trip

class Trip: NSManagedObject {
    var uniqueIDValue: NSNumber {
        get { return NSNumber(integerLiteral: Int(self.id)) }
        
        set(id) { self.id = Int64(truncating: id) }
    }
    
    var timeZone: TimeZone {
        return TimeZone(identifier: timeZoneIdentifier)!
    }
    
    var totalTimeInterval: TimeInterval {
        return endedAt.timeIntervalSince(startedAt)
    }
    
    var startCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude)
    }
    
    var endCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: endLatitude, longitude: endLongitude)
    }
    
    // MARK: Initializers
    
    convenience init() {
        let context = Store.shared.stack.unsafeContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context)
        
        self.init(entity: entity!, insertInto: context)
    }
}

// MARK: Conditions

extension Trip {
    func didOccur(_ condition: TripCondition) -> Bool {
        switch condition {
        case .weather(let type):
            return weather.contains(type.code)
        case .traffic(let type):
            return traffic.contains(type.code)
        case .road(let type):
            return roads.contains(type.code)
        case .light(let type):
            return light.contains(type.code)
        }
    }
    
    func set(_ didOccur: Bool, for condition: TripCondition) {
        func update(_ code: Character, on string: inout String) {
            if !didOccur {
                string.remove(code)
             
                return
            }
            
            string.add(code)
        }

        switch condition {
        case .weather(let type):
            update(type.code, on: &weather)
        case .traffic(let type):
            update(type.code, on: &traffic)
        case .road(let type):
            update(type.code, on: &roads)
        case .light(let type):
            update(type.code, on: &light)
        }
    }
}

// MARK: Importable

extension Trip: Importable {
    typealias ImportSource = JSON
    
    static let uniqueIDKeyPath = "id"
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        let resources = source["resources"]
        
        let carId = resources["car_id"].int64!
        
        car = transaction.fetchOne(From<Car>(), Where<Car>("id = \(carId)"))!
        
        let supervisorId = resources["supervisor_id"].int64!
        
        supervisor = transaction.fetchOne(From<Supervisor>(), Where<Supervisor>("id = \(supervisorId)"))!
        
        startedAt = source["started_at"].string!.utc(format: .dateTime)
        endedAt = source["ended_at"].string!.utc(format: .dateTime)
        odometer = source["odometer"].int32!
        distance = source["distance"].double!
        
        let conditions = source["conditions"]
        
        weather = conditions["weather"].string!
        traffic = conditions["traffic"].string!
        roads = conditions["roads"].string!
        light = conditions["light"].string!
        
        let coordinates = source["coordinates"]
        
        startLatitude = coordinates["start_latitude"].double!
        startLongitude = coordinates["start_longitude"].double!
        endLatitude = coordinates["end_latitude"].double!
        endLongitude = coordinates["end_longitude"].double!
        
        let location = source["location"]
        
        startLocation = location["start"].string!
        endLocation = location["end"].string!
        timeZoneIdentifier = location["timezone"].string!
    }
}

// MARK: Resourceable

extension Trip: Resourceable {
    static let resource = "trips"
    
    func toJSON() -> [String: Any] {
        return [
            "started_at": startedAt.utc(format: .dateTime),
            "ended_at": endedAt.utc(format: .dateTime),
            "odometer": odometer,
            "distance": distance,
            
            "car_id": car.id,
            "supervisor_id": supervisor.id,
            
            "weather": weather,
            "traffic": traffic,
            "roads": roads,
            "light": light,
            
            "start_latitude": startLatitude,
            "start_longitude": startLongitude,
            "end_latitude": endLatitude,
            "end_longitude": endLongitude,
            
            "start_location": startLocation,
            "end_location": endLocation,
            "timezone": timeZoneIdentifier
        ]
    }
}

// MARK: Core Data Properties

extension Trip {
    @NSManaged public var id: Int64
    @NSManaged public var startedAt: Date
    @NSManaged public var endedAt: Date
    @NSManaged public var odometer: Int32
    @NSManaged public var distance: Double
    
    @NSManaged public var weather: String
    @NSManaged public var traffic: String
    @NSManaged public var roads: String
    @NSManaged public var light: String

    @NSManaged public var startLatitude: Double
    @NSManaged public var startLongitude: Double
    @NSManaged public var endLatitude: Double
    @NSManaged public var endLongitude: Double
    
    @NSManaged public var startLocation: String
    @NSManaged public var endLocation: String
    @NSManaged public var timeZoneIdentifier: String
    
    @NSManaged public var car: Car
    @NSManaged public var supervisor: Supervisor
    
    @NSManaged public var isAccumulated: Bool
}
