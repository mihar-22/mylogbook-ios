
import Alamofire
import BEMCheckBox
import Charts
import CoreStore
import Dispatch
import DZNEmptyDataSet
import Foundation
import MapKit
import MBCircularProgressBar
import PopupDialog
import UIKit

class DashboardController: UIViewController {
    
    var lastRoute: LastRoute? { return Keychain.shared.getData(.lastRoute) }
    
    var statistics: Statistics = { return Cache.shared.statistics }()
    
    var residingState: AustralianState { return Cache.shared.residingState }
    
    let datePicker = UIDatePicker()
    
    let datePickerToolbar = UIToolbar()
    
    let tasks = Tasks()
    
    var editingTask: Task? = nil
    
    var isEmptyDataSet: Bool {
        return statistics.numberOfTrips == 0
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
    
    @IBOutlet weak var lastRouteCard: Card!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lastRouteTimeLabel: UILabel!
    @IBOutlet weak var lastRouteDistanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopSpace: NSLayoutConstraint!

    @IBOutlet weak var publishButton: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        tabBarController!.renderOriginalImages()
        
        configureTableView()
        
        BarChart.configure(barChartView)
        
        configureSegmentedControl()
        
        configureDatePicker()
        configureDatePickerToolbar()
        
        observeNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.emptyDataSetSource == nil { setupEmptyDataSet() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard !isEmptyDataSet else { return }
        
        reload()
        
        showLastRoute()
    }
    
    // MARK: Resets
    
    func reset() {
        resetTimeCard()
        
        statistics.calculate()
        
        lastRouteCard.isHidden = true
        
        publishButton.isEnabled = !isEmptyDataSet
        
        scrollContentView.isHidden = isEmptyDataSet
        
        scrollView.reloadEmptyDataSet()
    }
    
    func resetTimeCard() {
        dayTotalTime.alpha = 0
        
        nightTotalTime.alpha = 0
        
        dayProgressBar.value = 0
        
        nightProgressBar.value = 0
    }
    
    // MARK: Reload

    func reload() {
        reloadTasks()
        
        configureProgressBars()
        
        reloadBarChart()
    }
    
    func reloadTasks(animated: Bool = false) {
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
    
    // MARK: Actions
    
    @IBAction func didTapPublish(_ sender: UIBarButtonItem) {
        let composer = NswComposer()
        
        let html = composer.renderHTML()
        
        let webView = UIWebView(frame: CGRect(x: 0,
                                              y: 64,
                                              width: view.bounds.width,
                                              height: view.bounds.height - 49))
        
        view.addSubview(webView)
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func didTapEditButton(_ sender: UIButton) {
        let index = sender.tag
        
        editingTask = tasks[index]
        
        datePicker.isHidden = false
        datePickerToolbar.isHidden = false
    }
    
    func didTapDoneOnToolbar(_ sender: UIButton) {
        datePicker.isHidden = true
        datePickerToolbar.isHidden = true
        
        if let handler = editingTask?.editCompletionHandler {
            handler(datePicker.date)
            
            reloadTasks(animated: true)
            
            Cache.shared.save()
        }
    }
    
    // MARK: Notifications
    
    func observeNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(syncPreparationCompleted),
                                               name: Notification.syncPreparationComplete.name,
                                               object: nil)
    }
    
    func syncPreparationCompleted() {
        guard statistics.numberOfTrips == 0 else { return }
        
        reset()
        
        reload()
    }
}

// MARK: Empty Data Set

extension DashboardController: EmptyView, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func setupEmptyDataSet() {
        scrollView.emptyDataSetSource = self
        scrollView.emptyDataSetDelegate = self
        scrollView.reloadEmptyDataSet()
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty-dashboard")
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return isEmptyDataSet
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(title: "No Recordings")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return emptyView(description: "Data about your progress and trips will be here")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return emptyView(offset: -10)
    }
}

// MARK: Progress Card

extension DashboardController {
    func setProgressCardHeight() {
        tableViewTopSpace.constant = nightRequiredTimeStackView.isHidden ? -16 : 12
        
        let tableTopSpace = tableViewTopSpace.constant
        
        let tableHeight = tableView.contentSize.height
        
        progressCardHeight.constant = (base: 200) + tableTopSpace + tableHeight
        
        UIView.animate(withDuration: 0.35) { self.view.layoutIfNeeded() }
    }
    
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
        let (day, night) = residingState.loggedTimeRequired
        
        dayProgressBar.maxValue = CGFloat(day)
        
        nightProgressBar.maxValue = CGFloat(night)
    }
    
    func setProgressBarsHintLabels() {
        guard !residingState.is(.tasmania) && !residingState.is(.westernAustralia) else {
            hideRequiredTime(true)
            
            return
        }
        
        let secondsPerHour = 3600
        
        let dayMax = Int(dayProgressBar.maxValue) / secondsPerHour
        
        let nightMax = Int(nightProgressBar.maxValue) / secondsPerHour
        
        dayHoursRequiredLabel.text = "\(dayMax)"
        
        nightHoursRequiredLabel.text = "\(nightMax)"
        
        hideRequiredTime(false)
    }
    
    func hideRequiredTime(_ isHidden: Bool) {
        dayRequiredTimeStackView.isHidden = isHidden
        
        nightRequiredTimeStackView.isHidden = isHidden
        
        tableViewTopSpace.constant = isHidden ? -4 : 12
        
        setProgressCardHeight()
    }
}

// MARK: Segmented Controller

extension DashboardController {
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
            return .light
        case 2:
            return .traffic
        case 3:
            return .road
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
        cell.accessoryView = nil
        cell.hasBorder = true
        cell.setNeedsDisplay()
        
        if (task.learnMoreURL != nil) { addAccessoryView(for: cell, at: index) }
        
        if task is LogTask { cell.checkBox.isEnabled = false }
        
        if task is HoldTask { cell.checkBox.isEnabled = false }
        
        if task is AssessmentTask && task.subtitle != nil {
            cell.editButton.isHidden = false
            cell.editButton.tag = index
            cell.editButton.addTarget(self, action: #selector(didTapEditButton(_:)), for: .touchUpInside)
        }
    }
    
    func addAccessoryView(for cell: TaskCell, at index: Int) {
        let image = UIImage(named: "info")!
        
        let button = UIButton()
        
        button.tag = index
        button.setBackgroundImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        button.addTarget(self, action: #selector(didTapAccessoryView(_:)), for: .touchUpInside)
        
        cell.accessoryView = button
    }
    
    func didTapAccessoryView(_ sender: UIButton) {
        tableView(tableView, accessoryButtonTappedForRowWith: IndexPath(row: sender.tag, section: 0))
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            setProgressCardHeight()
        }
        
        if indexPath.row == (tasks.count - 1) {
            let cell = cell as! TaskCell
            
            cell.hasBorder = false
            
            cell.setNeedsDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard NetworkReachabilityManager()!.isReachable else {
            showOfflineAlert()
            
            return
        }
        
        let task = tasks[indexPath.row]
        
        UIApplication.shared.open(task.learnMoreURL!)
    }
}

// MARK: Alerting

extension DashboardController: Alerting {
    func showOfflineAlert() {
        let title = "Offline Mode"
        
        let message = "You are currently offline and the learn more option requires you to be online. Connect online and try again."
        
        let cancelButton = CancelButton(title: "OKAY", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
    }
}

// MARK: BEM Check Box Delegate

extension DashboardController: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        let index = checkBox.tag
        
        let task = tasks[index]
        
        if let handler = task.checkBoxHandler {
            handler(checkBox.on)
            
            reloadTasks(animated: true)
            
            statistics.calculate()
            
            configureProgressBars()
            
            Cache.shared.save()
        }
    }    
}

// MARK: Date Picker

extension DashboardController {
    func configureDatePicker() {
        datePicker.backgroundColor = UIColor.white
        datePicker.isHidden = true
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone(secondsFromGMT: 0)
        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.maximumDate = Date()
        datePicker.frame = CGRect(x: 0,
                                  y: view.bounds.height - tabBarController!.tabBar.frame.height - 180,
                                  width: view.bounds.width,
                                  height: 180)
        
        view.addSubview(datePicker)
    }
    
    func configureDatePickerToolbar() {
        datePickerToolbar.restyle(.normal)
        datePickerToolbar.addDoneButton(target: self, action: #selector(didTapDoneOnToolbar(_:)))
        datePickerToolbar.isHidden = true
        datePickerToolbar.frame = CGRect(x: 0,
                                     y: datePicker.frame.minY - datePickerToolbar.frame.height,
                                     width: view.bounds.width,
                                     height: datePickerToolbar.frame.height)
        
        view.addSubview(datePickerToolbar)
    }
}

// MARK: Map View Delegate

extension DashboardController: MKMapViewDelegate {
    func showLastRoute() {
        guard lastRoute != nil else { return }
        
        let deadline = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.lastRouteCard.isHidden = false
            
            self.setupLastRouteCard()
        }
    }

    func setupLastRouteCard() {
        lastRouteTimeLabel.text = lastRoute!.totalTime.time()
        
        lastRouteDistanceLabel.text = lastRoute!.distance.distance()
        
        setupMapView()
    }
    
    func setupMapView() {
        mapView.delegate = self
        
        let locations = lastRoute!.locations
        
        let center = locations[(locations.count - 1) / 2].coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        var coordinates = locations.map { $0.coordinate }
        
        let polyline = MKPolyline(coordinates: &coordinates,
                                  count: coordinates.count)
        
        mapView.removeOverlays(mapView.overlays)
        
        mapView.add(polyline)
        
        addAnnotations()
    }
    
    func addAnnotations() {
        let startAnnotation = MKPointAnnotation()
        
        startAnnotation.title = "Started Here"
        
        startAnnotation.subtitle = lastRoute!.startedAt.local(date: .none, time: .short)
        
        startAnnotation.coordinate = lastRoute!.locations.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"
        
        endAnnotation.subtitle = lastRoute!.endedAt.local(date: .none, time: .short)
        
        endAnnotation.coordinate = lastRoute!.locations.last!.coordinate
        
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotations([startAnnotation, endAnnotation])
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = Palette.tint.uiColor
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pin.pinTintColor = Palette.tint.uiColor
        
        pin.canShowCallout = true
        
        return pin
    }
}
