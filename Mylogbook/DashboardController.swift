
import Charts
import CoreStore
import Dispatch
import MapKit
import MBCircularProgressBar
import UIKit

class DashboardController: UIViewController {
    
    var trips: [Trip]!
    
    var locations: [CLLocation]? { return Keychain.shared.lastRoute }
    
    // MARK: Outlets
    
    @IBOutlet weak var dayProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var dayTotalTime: UILabel!
    
    @IBOutlet weak var nightProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var nightTotalTime: UILabel!
    
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var totalTripsLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRouteTimeLabel: UILabel!
    @IBOutlet weak var lastRouteDistanceLabel: UILabel!
    
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        configureBarChart()
        
        chartSegmentedControl.addTarget(self,
                                        action: #selector(segmentedControlChanged(_:)),
                                        for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetProgressBars()
        
        mapView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        trips = Store.shared.stack.fetchAll(From<Trip>(),
                                            OrderBy(.ascending("startedAt")))
        
        buildProgressBars()
        
        chartSegmentedControl.selectedSegmentIndex = 0
        
        rebuildBarChart()
        
        let deadline = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.mapView.isHidden = false
            
            self.buildLastRoute()
        }
    }
    
    // MARK: Reset
    
    func resetProgressBars() {
        dayTotalTime.alpha = 0
        
        nightTotalTime.alpha = 0
        
        dayProgressBar.value = 0
        
        nightProgressBar.value = 0
    }
    
    // MARK: Progress Bars
    
    func buildProgressBars() {
        let (totalDayTime, totalNightTime) = TripCalculator.calculateTotal(forAll: trips)
        
        let units: NSCalendar.Unit = [.hour, .minute]
        
        dayTotalTime.text = TimeInterval(totalDayTime).abbreviatedTime(in: units)

        nightTotalTime.text = TimeInterval(totalNightTime).abbreviatedTime(in: units)

        let totalDayTimeHours = CGFloat(totalDayTime / (secsInHour: 3600))
        
        let totalNightTimeHours = CGFloat(totalNightTime / (secsInHour: 3600))
        
        UIView.animate(withDuration: 1.0) {
            self.dayTotalTime.alpha = 1
            
            self.nightTotalTime.alpha = 1
            
            self.dayProgressBar.value = totalDayTimeHours < 110 ? totalDayTimeHours : 110
            
            self.nightProgressBar.value = totalNightTimeHours < 10 ? totalNightTimeHours : 10
        }
    }
    
    // MARK: Segmented Controller
    
    func segmentedControlChanged(_ control: UISegmentedControl) {
        rebuildBarChart()
    }
    
    func currentChartSegment() -> ChartSegment {
        switch chartSegmentedControl.selectedSegmentIndex {
        case 0:
            return .weather
        case 1:
            return .traffic
        case 2:
            return  .road
        default:
            return .weather
        }
    }
    
    // MARK: Bar Chart
    
    func configureBarChart() {
        barChartView.noDataText = "No trips have been recorded."
        
        barChartView.xAxis.enabled = true
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelTextColor = UIColor.white
        
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false

        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.highlightPerTapEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        
        barChartView.legend.horizontalAlignment = .center
        barChartView.legend.neededHeight = 10.0
        barChartView.legend.formToTextSpace = 5.0
        
        barChartView.animate(yAxisDuration: 1.0)
    }
    
    func rebuildBarChart() {
        buildBarChart(for: currentChartSegment())
        
        totalTripsLabel.text = "\(trips.count)"
    }
    
    func buildBarChart(for segment: ChartSegment) {
        guard segment.all().map({ $0.data(for: trips) > 0 }).contains(true) else { return }

        var sets = [BarChartDataSet]()
        
        for (index, item) in segment.all().enumerated() {
            let entry = BarChartDataEntry(x: Double(index), y: item.data(for: trips))
            
            let set = BarChartDataSet(values: [entry], label: item.label)
            
            set.setColor(item.color)
            
            set.valueFont = UIFont.systemFont(ofSize: 12)
            
            sets.append(set)
        }
        
        barChartView.data = BarChartData(dataSets: sets)
        
        barChartView.data?.setValueFormatter(ChartValueFormatter())
        
        barChartView.fitBars = true
        
        barChartView.animate(yAxisDuration: 1.0)
    }
    
    // MARK: Last Route
    
    func buildLastRoute() {
        guard locations != nil && locations!.count > 0 && trips.count > 0 else { return }
        
        let lastTrip = trips.last!
        
        let totalTimeInterval = lastTrip.endedAt!.timeIntervalSince(lastTrip.startedAt!)
        
        lastRouteTimeLabel.text = totalTimeInterval.abbreviatedTime
        
        lastRouteDistanceLabel.text = lastTrip.distance.toMeters.abbreviatedDistance
        
        setupMapView()
    }
}

// MARK: Map View Delegate

extension DashboardController: MKMapViewDelegate {
    func setupMapView() {
        mapView.delegate = self
        
        let center = locations![(locations!.count - 1) / 2].coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        var coordinates = locations!.map { $0.coordinate }
        
        let polyline = MKPolyline(coordinates: &coordinates,
                                  count: coordinates.count)
        
        mapView.add(polyline)
        
        addAnnotations()
    }
    
    func addAnnotations() {
        let startAnnotation = MKPointAnnotation()
        
        startAnnotation.title = "Started Here"
        
        startAnnotation.subtitle = trips.last!.startedAt!.shortTime
        
        startAnnotation.coordinate = locations!.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"
        
        endAnnotation.subtitle = trips.last!.endedAt!.shortTime
        
        endAnnotation.coordinate = locations!.last!.coordinate
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = DarkTheme.brand.uiColor
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pin.pinTintColor = DarkTheme.brand.uiColor
        
        pin.canShowCallout = true
        
        return pin
    }
}
