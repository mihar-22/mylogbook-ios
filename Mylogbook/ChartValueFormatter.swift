
import Charts

// MARK: Chart Value Formatter

class ChartValueFormatter: NSObject, IValueFormatter {
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        
        let _value = Int(value)
        
        return value == 1.0 ? "\(_value) trip" : "\(_value) trips"
    }
}
