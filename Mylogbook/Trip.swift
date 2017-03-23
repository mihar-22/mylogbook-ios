
import CoreStore
import SwiftyJSON

// MARK: Trip

class Trip: NSManagedObject {
    var uniqueIDValue: Int {
        get { return self.id }
        
        set(id) { self.id = id }
    }
    
    var timeZone: TimeZone {
        return TimeZone(identifier: timeZoneIdentifier)!
    }
    
    var totalTime: TimeInterval {
        return endedAt.timeIntervalSince(startedAt)
    }
    
    // MARK: Initializers
    
    convenience init() {
        let context = Store.shared.stack.internalContext()
        
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
        let carId = source["car_id"].int!
        
        car = transaction.fetchOne(From(Car.self),
                                   Where("id = \(carId)"))!
        
        let supervisorId = source["supervisor_id"].int!
        
        supervisor = transaction.fetchOne(From(Supervisor.self),
                                          Where("id = \(supervisorId)"))!
        
        startedAt = source["started_at"].string!.utc(format: .dateTime)
        endedAt = source["ended_at"].string!.utc(format: .dateTime)
        odometer = source["odometer"].int!
        distance = source["distance"].double!
        
        weather = source["weather"].string!
        traffic = source["traffic"].string!
        roads = source["roads"].string!
        light = source["light"].string!
        
        startLatitude = source["start_latitude"].double!
        startLongitude = source["start_longitude"].double!
        endLatitude = source["end_latitude"].double!
        endLongitude = source["end_longitude"].double!
        timeZoneIdentifier = source["timezone"].string!
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
            "timezone": timeZoneIdentifier
        ]
    }
}

// MARK: Core Data Properties

extension Trip {
    @NSManaged public var id: Int
    @NSManaged public var startedAt: Date
    @NSManaged public var endedAt: Date
    @NSManaged public var odometer: Int
    @NSManaged public var distance: Double
    
    @NSManaged public var weather: String
    @NSManaged public var traffic: String
    @NSManaged public var roads: String
    @NSManaged public var light: String

    @NSManaged public var startLatitude: Double
    @NSManaged public var startLongitude: Double
    @NSManaged public var endLatitude: Double
    @NSManaged public var endLongitude: Double
    @NSManaged public var timeZoneIdentifier: String
    
    @NSManaged public var car: Car
    @NSManaged public var supervisor: Supervisor
    
    @NSManaged public var isAccumulated: Bool
}
