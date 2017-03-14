
import Charts

// MARK: Bar Chart

class BarChart {
    static func configure(_ view: BarChartView) {
        view.noDataText = "No trips have been recorded."
        
        view.xAxis.enabled = true
        view.xAxis.drawAxisLineEnabled = false
        view.xAxis.drawGridLinesEnabled = false
        view.xAxis.labelPosition = .bottom
        view.xAxis.labelTextColor = UIColor.white
        
        view.rightAxis.enabled = false
        
        view.leftAxis.enabled = false
        view.leftAxis.axisMinimum = 0
        
        view.chartDescription?.enabled = false
        view.pinchZoomEnabled = false
        view.drawGridBackgroundEnabled = false
        view.highlightPerTapEnabled = false
        view.highlightFullBarEnabled = false
        view.highlightPerDragEnabled = false
        view.doubleTapToZoomEnabled = false
        
        view.legend.horizontalAlignment = .center
        view.legend.neededHeight = 10.0
        view.legend.formToTextSpace = 5.0
        
        view.animate(yAxisDuration: 1.0)
    }
        
    static func build(_ view: BarChartView, for segment: ChartSegment) {
        guard segment.all().map({ $0.data > 0 }).contains(true) else { return }
        
        var sets = [BarChartDataSet]()
        
        for (index, item) in segment.all().enumerated() {
            let entry = BarChartDataEntry(x: Double(index), y: item.data)
            
            let set = BarChartDataSet(values: [entry], label: item.label)
            
            set.setColor(item.color)
            
            set.valueFont = UIFont.systemFont(ofSize: 12)
            
            sets.append(set)
        }
        
        view.data = BarChartData(dataSets: sets)
        
        view.data?.setValueFormatter(ChartValueFormatter())
        
        view.fitBars = true
        
        view.animate(yAxisDuration: 1.0)
    }
}
