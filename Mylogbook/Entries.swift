
import Foundation

// MARK: Entries

class Entries: NSObject, NSCoding {
    var day = 0
    
    var night = 0
    
    var dayBonus: Int? = nil
    
    var nightBonus: Int? = nil
    
    var isHazardsComplete = false
    
    var isDrivingTestComplete = false
    
    var isSaferDriversComplete: Bool? = nil
    
    var isAssessmentComplete: Bool? = nil
    
    var assessmentCompletedAt: Date? = nil
    
    // MARK: Encoding + Decoding
    
    override init() { super.init() }
    
    required init?(coder aDecoder: NSCoder) {
        day = aDecoder.decodeInteger(forKey: "day")
        night = aDecoder.decodeInteger(forKey: "night")
        dayBonus = aDecoder.decodeObject(forKey: "dayBonus") as? Int
        nightBonus = aDecoder.decodeObject(forKey: "nightBonus") as? Int
        isHazardsComplete = aDecoder.decodeBool(forKey: "isHazardsComplete")
        isDrivingTestComplete = aDecoder.decodeBool(forKey: "isDrivingTestComplete")
        isSaferDriversComplete = aDecoder.decodeObject(forKey: "isSaferDriversComplete") as? Bool
        isAssessmentComplete = aDecoder.decodeObject(forKey: "isAssessmentComplete") as? Bool
        assessmentCompletedAt = aDecoder.decodeObject(forKey: "assessmentCompletedAt") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(day, forKey: "day")
        aCoder.encode(night, forKey: "night")
        aCoder.encode(dayBonus, forKey: "dayBonus")
        aCoder.encode(nightBonus, forKey: "nightBonus")
        aCoder.encode(isHazardsComplete, forKey: "isHazardsComplete")
        aCoder.encode(isDrivingTestComplete, forKey: "isDrivingTestComplete")
        aCoder.encode(isSaferDriversComplete, forKey: "isSaferDriversComplete")
        aCoder.encode(isAssessmentComplete, forKey: "isAssessmentComplete")
        aCoder.encode(assessmentCompletedAt, forKey: "assessmentCompletedAt")
    }
}
