
import BEMCheckBox
import Charts
import CoreStore
import Dispatch
import MapKit
import MBCircularProgressBar
import UIKit

class DashboardController: UIViewController {
    
    var locations: [CLLocation]? { return Keychain.shared.getData(.lastRoute) }
    
    var statistics: Statistics = { return Cache.shared.statistics }()
    
    let tasks = Tasks()
    
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
        
        BarChart.configure(barChartView)
        
        configureSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reload()
    }
    
    // MARK: Resets
    
    func reset() {
        resetTimeCard()
        
        mapView.isHidden = true
        
        statistics.calculate()

        reloadTableViewData()
    }
    
    func resetTimeCard() {
        dayTotalTime.alpha = 0
        
        nightTotalTime.alpha = 0
        
        dayProgressBar.value = 0
        
        nightProgressBar.value = 0
    }
    
    // MARK: Reload

    func reload() {
        configureProgressBars()
        
        reloadBarChart()
        
        reloadMap()
    }
    
    func reloadTableViewData(animated: Bool = false) {
        tasks.build()
        
        guard animated else {
            tableView.reloadData()
            
            return
        }
        
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() },
                          completion: nil)
    }
    
    func reloadBarChart() {
        chartSegmentedControl.selectedSegmentIndex = 0
        
        BarChart.build(barChartView, for: currentChartSegment())
        
        totalTripsLabel.text = "\(statistics.numberOfTrips)"
    }
    
    func reloadMap() {
        let deadline = DispatchTime.now() + .seconds(1)
            
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.mapView.isHidden = false
        }
    }
    
    // MARK: Progress Bars
    
    func configureProgressBars() {
        setProgressBarsMaxValues()
        
        setProgressBarsValues()
        
        setProgressBarsHintLabels()
    }
    
    func setProgressBarsValues() {
        let (day, night) = (statistics.dayLogged, statistics.nightLogged)
        
        dayTotalTime.text = TimeInterval(day).time(in: [.hour, .minute])
        
        nightTotalTime.text = TimeInterval(night).time(in: [.hour, .minute])
        
        UIView.animate(withDuration: 1.0) {
            self.dayTotalTime.alpha = 1
            
            self.nightTotalTime.alpha = 1
            
            self.dayProgressBar.value = min(CGFloat(day), self.dayProgressBar.maxValue)
            
            self.nightProgressBar.value = min(CGFloat(night), self.nightProgressBar.maxValue)
        }
    }
    
    func setProgressBarsMaxValues() {
        let (day, night) = Cache.shared.residingState.loggedTimeRequired
        
        dayProgressBar.maxValue = CGFloat(day)
        
        nightProgressBar.maxValue = CGFloat(night)
    }
    
    func setProgressBarsHintLabels() {
        let secondsPerHour = 3600
                
        let dayMax = Int(dayProgressBar.maxValue) / secondsPerHour
        
        let nightMax = Int(nightProgressBar.maxValue) / secondsPerHour
        
        dayHoursRequiredLabel.text = "\(dayMax)"
        
        nightHoursRequiredLabel.text = "\(nightMax)"
    }
    
    // MARK: Segmented Controller
    
    func configureSegmentedControl() {
        chartSegmentedControl.addTarget(self,
                                        action: #selector(segmentedControlChanged(_:)),
                                        for: .valueChanged)
    }
    
    func segmentedControlChanged(_ control: UISegmentedControl) {
        BarChart.build(barChartView, for: currentChartSegment())
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
}

// MARK: Table View Data Source + Delegate

extension DashboardController: UITableViewDataSource, UITableViewDelegate {
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 59
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        configure(cell, for: indexPath.row)
        
        return cell
    }
    
    func configure(_ cell: TaskCell, for index: Int) {
        let task = tasks[index]
        
        cell.titleLabel.textColor = task.isActive ? UIColor.black : UIColor.lightGray
        cell.titleLabel.attributedText = task.title
        
        cell.subtitleLabel.text = task.subtitle
        
        cell.checkBox.on = (task.isActive && task.isComplete)
        cell.checkBox.isEnabled = task.isActive
        cell.checkBox.onAnimationType = .fill
        cell.checkBox.offAnimationType = .flat
        cell.checkBox.tag = index
        cell.checkBox.delegate = self

        cell.editButton.isHidden = true

        if task is LogTask {
            cell.checkBox.isEnabled = false
        }
        
        if task is HoldTask {
            cell.checkBox.isEnabled = false
        }
        
        if task is AssessmentTask && task.subtitle != nil {
            cell.editButton.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            progressCardHeight.constant = (base: 209.5) + tableView.contentSize.height
        }
    }
    
}

// MARK: BEM Check Box Delegate

extension DashboardController: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        let index = checkBox.tag
        
        let task = tasks[index]
        
        if let handler = task.checkBoxHandler {
            handler(checkBox.on)
            
            reloadTableViewData(animated: true)
            
            statistics.calculate()
            
            configureProgressBars()
            
            Cache.shared.save()
        }
    }    
}

// FIX!

// MARK: Map View Delegate

extension DashboardController: MKMapViewDelegate {
    func buildLastRoute() {
        // guard locations != nil && locations!.count > 0 && trips.count > 0 else { return }
        
        guard locations != nil && locations!.count > 0 else { return }
        
        // let lastTrip = trips.last!
        
        // lastRouteTimeLabel.text = lastTrip.totalTime.time()
        
        // lastRouteDistanceLabel.text = lastTrip.distance.distance()
        
        lastRouteTimeLabel.text = "0s"
        
        lastRouteDistanceLabel.text = "0m"
        
        setupMapView()
    }
    
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
        
        // startAnnotation.subtitle = trips.last!.startedAt.string(date: .none, time: .short)
        
        startAnnotation.coordinate = locations!.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"
        
        // endAnnotation.subtitle = trips.last!.endedAt.string(date: .none, time: .short)
        
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
