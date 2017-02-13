
import ObjectMapper

// MARK: Date Transfomer

struct DateTransformer: TransformType {
    typealias Object = Date
    
    typealias JSON = String
    
    func transformFromJSON(_ value: Any?) -> Date? {
        guard let date = value as? String else { return nil }

        return date.dateFromISO8601        
    }
    
    func transformToJSON(_ value: Date?) -> String? {
        return value?.description
    }
}
