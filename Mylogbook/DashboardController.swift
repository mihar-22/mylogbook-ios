
import Charts
import CoreStore
import Dispatch
import MapKit
import MBCircularProgressBar
import UIKit

class DashboardController: UIViewController {
    
    var trips: [Trip]!
    
    var locations: [CLLocation]? { return Keychain.shared.getData(.lastRoute) }
    
    var isL1RequirementsMet: Bool {
        let settings = Settings.shared.currentEntries
        
        let isAssessmentComplete = settings.isAssessmentComplete ?? false
        
        let isHoursLogged = (dayProgressBar.value + nightProgressBar.value) > 108_000
        
        let licenseReceivedAt = Keychain.shared.get(.permitReceivedAt)!.date(format: .date)
        
        let isTimeRequirementMet = Calendar.current.dateComponents([.month],
                                                                   from: licenseReceivedAt,
                                                                   to: Date()).month! >= 3
        
        return isAssessmentComplete && isHoursLogged && isTimeRequirementMet
    }
    
    var isStage2RequirementsMet: Bool {
        let settings = Settings.shared.currentEntries
        
        let isAssessmentComplete = settings.isAssessmentComplete ?? false
        
        let isHoursLogged = (dayProgressBar.value + nightProgressBar.value) > 90_000
        
        return isAssessmentComplete && isHoursLogged
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var progressCardHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dayProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var dayTotalTime: UILabel!
    @IBOutlet weak var dayHoursRequiredLabel: UILabel!
    @IBOutlet weak var dayRequiredTimeStackView: UIStackView!
    
    @IBOutlet weak var nightProgressBar: MBCircularProgressBarView!
    @IBOutlet weak var nightTotalTime: UILabel!
    @IBOutlet weak var nightHoursRequiredLabel: UILabel!
    @IBOutlet weak var nightRequiredTimeStackView: UIStackView!
    
    @IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var totalTripsLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRouteTimeLabel: UILabel!
    @IBOutlet weak var lastRouteDistanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        configureTableView()
        
        configureBarChart()
        
        chartSegmentedControl.addTarget(self,
                                        action: #selector(segmentedControlChanged(_:)),
                                        for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetTimeCard()
        
        mapView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        trips = Store.shared.stack.fetchAll(From<Trip>(),
                                            OrderBy(.ascending("startedAt")))
        
        setupProgressBars()
        
        chartSegmentedControl.selectedSegmentIndex = 0
        
        rebuildBarChart()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.mapView.isHidden = false
        }
    }
    
    // MARK: Reset
    
    func resetTimeCard() {
        dayTotalTime.alpha = 0
        
        nightTotalTime.alpha = 0
        
        dayProgressBar.value = 0
        
        nightProgressBar.value = 0
    }
    
    // MARK: Progress Bars
    
    func setupProgressBars() {
        setProgressBarsMaxValues()
        
        setProgressBarsValues()
        
        setProgressBarsHintLabels()
    }
    
    func setProgressBarsValues() {
        let (totalDay, totalNight) = TripCalculator.calculateTotal(forAll: trips)
        
        dayTotalTime.text = TimeInterval(totalDay).time(in: [.hour, .minute])
        
        nightTotalTime.text = TimeInterval(totalNight).time(in: [.hour, .minute])
        
        UIView.animate(withDuration: 1.0) {
            self.dayTotalTime.alpha = 1
            
            self.nightTotalTime.alpha = 1
            
            self.dayProgressBar.value = min(CGFloat(totalDay), self.dayProgressBar.maxValue)
            
            self.nightProgressBar.value = min(CGFloat(totalNight), self.nightProgressBar.maxValue)
        }
    }
    
    func setProgressBarsMaxValues() {
        switch Settings.shared.residingState {
        case .victoria:
            dayProgressBar.maxValue = 396_000
            nightProgressBar.maxValue = 36_000
        case .newSouthWhales:
            dayProgressBar.maxValue = 360_000
            nightProgressBar.maxValue = 72_000
        case .queensland:
            dayProgressBar.maxValue = 324_000
            nightProgressBar.maxValue = 36_000
        case .southAustralia:
            dayProgressBar.maxValue = 216_000
            nightProgressBar.maxValue = 54_000
        case .tasmania:
            let max: CGFloat = isL1RequirementsMet ? 288_000 : 108_000
            
            dayProgressBar.maxValue = max
            nightProgressBar.maxValue = max
        case .westernAustralia:
            let max: CGFloat = isStage2RequirementsMet ? 180_000 : 90_000

            dayProgressBar.maxValue = max
            nightProgressBar.maxValue = max
        }
    }
    
    func setProgressBarsHintLabels() {
        let secondsPerHour = 3600
                
        let dayMax = Int(dayProgressBar.maxValue) / secondsPerHour
        
        let nightMax = Int(nightProgressBar.maxValue) / secondsPerHour
        
        dayHoursRequiredLabel.text = "\(dayMax)"
        
        nightHoursRequiredLabel.text = "\(nightMax)"
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
        barChartView.leftAxis.axisMinimum = 0

        barChartView.chartDescription?.enabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        barChartView.highlightPerTapEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.highlightPerDragEnabled = false
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
        
        lastRouteTimeLabel.text = lastTrip.totalTime.time()

        lastRouteDistanceLabel.text = lastTrip.distance.distance()
        
        setupMapView()
    }
}

// MARK: Table View Data Source + Delegate

extension DashboardController: UITableViewDataSource, UITableViewDelegate {
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 61
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressCell", for: indexPath) as! ProgressCell
        
        cell.subtitleLabel.text = ""
        
        cell.checkBox.onAnimationType = .fill
        cell.checkBox.offAnimationType = .flat
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {

        addDashedBottomBorder(to: cell)
        
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            progressCardHeight.constant = 209.6 + tableView.contentSize.height
        }
    }
    
    func addDashedBottomBorder(to cell: UITableViewCell) {
        let border: CAShapeLayer = CAShapeLayer()
        
        let color = DarkTheme.base(.divider).uiColor.cgColor
        
        let cellFrame = cell.frame.size
        
        let bounds = CGRect(x: 0, y: 0, width: cellFrame.width - 12, height: 0)
        
        let bezierRect = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 0)
        
        border.bounds = bounds
        border.position = CGPoint(x: cellFrame.width / 2, y: cellFrame.height)
        border.fillColor = color
        border.strokeColor = color
        border.lineWidth = 2.0
        border.lineJoin = kCALineJoinMiter
        border.lineDashPattern = [3, 3]
        border.path = UIBezierPath(roundedRect: bezierRect, cornerRadius: 0).cgPath
        
        cell.layer.addSublayer(border)
    }
}

// MARK: Map View Delegate

extension DashboardController: MKMapViewDelegate {
    func setupMapView() {
        mapView.delegate = self
        
        let center = locations![(locations!.count - 1) / 2].coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
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
        
        startAnnotation.subtitle = trips.last!.startedAt.string(date: .none, time: .short)
        
        startAnnotation.coordinate = locations!.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"
        
        endAnnotation.subtitle = trips.last!.endedAt.string(date: .none, time: .short)
        
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
