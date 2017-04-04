
import CoreLocation
import Foundation

// MARK: Last Route

class LastRoute: NSObject, NSCoding {
    var startedAt: Date
    var endedAt: Date
    var locations: [CLLocation]
    var distance: Double
    
    var totalTimeInterval: TimeInterval {
        return endedAt.timeIntervalSince(startedAt)
    }
    
    // MARK: Initializers
    
    init(startedAt: Date, endedAt: Date, locations: [CLLocation], distance: Double) {
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.locations = locations
        self.distance = distance
        
        super.init()
    }
    
    // MARK: Encoding
    
    required init?(coder aDecoder: NSCoder) {
        startedAt = aDecoder.decodeObject(forKey: "startedAt") as! Date
        endedAt = aDecoder.decodeObject(forKey: "endedAt") as! Date
        locations = aDecoder.decodeObject(forKey: "locations") as! [CLLocation]
        distance = aDecoder.decodeDouble(forKey: "distance")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startedAt, forKey: "startedAt")
        aCoder.encode(endedAt, forKey: "endedAt")
        aCoder.encode(locations, forKey: "locations")
        aCoder.encode(distance, forKey: "distance")
    }
}
