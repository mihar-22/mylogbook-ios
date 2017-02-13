
import CoreStore
import ObjectMapper

// MARK: Trip

class Trip: NSManagedObject, Resourceable, Syncable {
    static let resource = "trips"
    
    var createdAt: Date? { get { return startedAt } set {} }
    
    var updatedAt: Date? = nil
    
    var deletedAt: Date? = nil
    
    // MARK: Car Id
    
    private var carIdProxy: Int?
    
    var carId: Int? {
        get {
            return (car != nil) ? car!.id : carIdProxy
        }
        
        set(id) {
            if (car != nil) { car!.id = id! }
            else { carIdProxy = id }
        }
    }
    
    // MARK: Supervisor Id
    
    private var supervisorIdProxy: Int?
    
    var supervisorId: Int? {
        get {
            return (supervisor != nil) ? supervisor!.id : supervisorIdProxy
        }
        
        set(id) {
            if (supervisor != nil) { supervisor!.id = id! }
            else { supervisorIdProxy = id }
        }
    }
    
    // MARK: Initializers
    
    required convenience init?(map: Map) {
        let context = Store.shared.stack.internalContext()
        
        let entity = NSEntityDescription.entity(forEntityName: "Trip", in: context)
        
        self.init(entity: entity!, insertInto: context)
    }
    
    // MARK: Mappable
    
    func mapping(map: Map) {
        id                       <- map["id"]
        startedAt                <- (map["started_at"], DateTransformer())
        endedAt                  <- (map["ended_at"], DateTransformer())
        odometer                 <- map["odometer"]
        distance                 <- map["distance"]
        
        carId                    <- map["car_id"]
        supervisorId             <- map["supervisor_id"]
        
        clear                    <- map["weather.clear"]
        rain                     <- map["weather.rain"]
        thunder                  <- map["weather.thunder"]
        
        light                    <- map["traffic.light"]
        moderate                 <- map["traffic.moderate"]
        heavy                    <- map["traffic.heavy"]
        
        localStreet              <- map["roads.local_street"]
        mainRoad                 <- map["roads.main_road"]
        innerCity                <- map["roads.inner_city"]
        freeway                  <- map["roads.freeway"]
        ruralHighway             <- map["roads.rural_highway"]
        gravel                   <- map["roads.gravel"]
    }
    
    // MARK: Fillable
    
    let fillables = [
        "startedAt",
        "endedAt",
        "odometer",
        "distance",
        "clear",
        "rain",
        "thunder",
        "light",
        "moderate",
        "heavy",
        "localStreet",
        "mainRoad",
        "innerCity",
        "freeway",
        "ruralHighway",
        "gravel"
    ]

    func relationships() -> [String : Int]? {
        return [
            "car": carId!,
            "supervisor": supervisorId!
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
