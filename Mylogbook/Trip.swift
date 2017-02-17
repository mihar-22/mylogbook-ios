
import CoreStore
import SwiftyJSON

// MARK: Trip

class Trip: NSManagedObject {
    var uniqueIDValue: Int {
        get { return self.id }
        
        set(id) { self.id = id }
    }
    
    // MARK: Initializers
    
    convenience init() {
        let context = Store.shared.stack.internalContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context)
        
        self.init(entity: entity!, insertInto: context)
    }
}

// MARK: Importable

extension Trip: Importable {
    typealias ImportSource = JSON
    
    static let uniqueIDKeyPath = "id"
    
    func update(from source: JSON, in transaction: BaseDataTransaction) throws {
        let carId = source["car_id"].int!
        
        car = transaction.fetchOne(From(Car.self),
                                   Where("id = \(carId)"))
        
        let supervisorId = source["supervisor_id"].int!
        
        supervisor = transaction.fetchOne(From(Supervisor.self),
                                          Where("id = \(supervisorId)"))
        
        startedAt = source["started_at"].string?.dateFromISO8601
        endedAt = source["ended_at"].string?.dateFromISO8601
        odometer = source["odometer"].int!
        distance = source["distance"].double!
        
        let weather = source["weather"]
        
        clear = weather["clear"].bool!
        rain = weather["rain"].bool!
        thunder = weather["thunder"].bool!
        
        let traffic = source["traffic"]
        
        light = traffic["light"].bool!
        moderate = traffic["moderate"].bool!
        heavy = traffic["heavy"].bool!

        let roads = source["roads"]
        
        localStreet = roads["local_street"].bool!
        mainRoad = roads["main_road"].bool!
        innerCity = roads["inner_city"].bool!
        freeway = roads["freeway"].bool!
        ruralHighway = roads["rural_highway"].bool!
        gravel = roads["gravel"].bool!
    }
}

// MARK: Resourceable

extension Trip: Resourceable {
    static let resource = "trips"
    
    func toJSON() -> [String: Any] {
        return [
            "started_at": startedAt!.iso8601,
            "ended_at": endedAt!.iso8601,
            "odometer": odometer,
            "distance": distance,
            "car_id": car!.id,
            "supervisor_id": supervisor!.id,
            "weather": [
                "clear": clear,
                "rain": rain,
                "thunder": thunder
            ],
            "traffic": [
                "light": light,
                "moderate": moderate,
                "heavy": heavy
            ],
            "roads": [
                "local_street": localStreet,
                "main_road": mainRoad,
                "inner_city": innerCity,
                "freeway": freeway,
                "rural_highway": ruralHighway,
                "gravel": gravel
            ]
        ]
    }
}

// MARK: Core Data Properties

extension Trip {
    @NSManaged public var id: Int
    @NSManaged public var startedAt: Date?
    @NSManaged public var endedAt: Date?
    @NSManaged public var odometer: Int
    @NSManaged public var distance: Double
    
    @NSManaged public var car: Car?
    @NSManaged public var supervisor: Supervisor?
    
    @NSManaged public var clear: Bool
    @NSManaged public var rain: Bool
    @NSManaged public var thunder: Bool

    @NSManaged public var light: Bool
    @NSManaged public var moderate: Bool
    @NSManaged public var heavy: Bool

    @NSManaged public var localStreet: Bool
    @NSManaged public var mainRoad: Bool
    @NSManaged public var innerCity: Bool
    @NSManaged public var freeway: Bool
    @NSManaged public var ruralHighway: Bool
    @NSManaged public var gravel: Bool
}