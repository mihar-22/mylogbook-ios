
import Alamofire
import BEMCheckBox
import Charts
import CoreStore
import Dispatch
import DZNEmptyDataSet
import Foundation
import MapKit
import MBCircularProgressBar
import MessageUI
import PopupDialog
import UIKit

class DashboardController: UIViewController, ActivityView {
    
    var lastRoute: LastRoute? { return Keychain.shared.getData(.lastRoute) }
    
    var statistics: Statistics = { return Cache.shared.statistics }()
    
    var residingState: AustralianState { return Cache.shared.residingState }
    
    let datePicker = UIDatePicker()
    
    let datePickerToolbar = UIToolbar()
    
    let tasks = Tasks()
    
    var editingTask: Task? = nil
    
    var secondaryPdf: Data? = nil
    
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
        
        statistics.update()
        
        mapView.isHidden = true
        
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
        
        totalTripsLabel.text = String(statistics.numberOfTrips)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPublish(_ sender: UIBarButtonItem) {
        let publishButton = self.publishButton
        
        var composer: LogbookComposer!
        
        var secondaryComposer: LogbookComposer? = nil
        
        switch self.residingState {
        case .victoria:
            composer = VicComposer()
        case .newSouthWhales:
            composer = NswComposer()
        case .queensland:
            composer = QldComposer()
        case .southAustralia:
            composer = SaComposer(version: .day)
            
            secondaryComposer = SaComposer(version: .night)
        case .tasmania:
            composer = TasComposer()
        case .westernAustralia:
            composer = WaComposer()
        }
        
        showActivityIndicator()

        DispatchQueue.main.async {
            let pdf = composer.createPDF()
            
            self.secondaryPdf = secondaryComposer?.createPDF() as? Data
            
            self.showExportActionSheet(for: pdf)
            
            self.hideActivityIndicator(replaceWith: publishButton)
        }
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
        
        showLastRoute()
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
    
    func showExportActionSheet(for pdf: NSData) {
        let title = "How would you like to export your logbook?"
        
        let actionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .default) { _ in
            self.exportWithMail(pdf)
        }
        
        let printAction = UIAlertAction(title: "Print", style: .default) { _ in
            self.exportWithPrinter(pdf)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(emailAction)
        actionSheet.addAction(printAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showMailCannotSendAlert() {
        let title = "Setup Mail"
        
        let message = "The email cannot be sent because you have not setup mail on this device."

        let settingsButton = DefaultButton(title: "SETTINGS") {
            let url = URL(string: "App-Prefs:root=Mail")!
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let cancelButton = CancelButton(title: "CANCEL", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton, settingsButton])
    }
    
    func showPrintingNotAvailableAlert() {
        let title = "Printing Not Available"
        
        let message = "Your device does not support printing."
        
        let cancelButton = CancelButton(title: "OKAY", action: nil)
        
        showAlert(title: title, message: message, buttons: [cancelButton])
    }
}

// MARK: Export

extension DashboardController {
    func exportWithMail(_ pdf: NSData) {
        guard MFMailComposeViewController.canSendMail() else {
            showMailCannotSendAlert()
            
            return
        }

        let email = Keychain.shared.get(.email)!
        
        let mailer = MFMailComposeViewController()

        mailer.mailComposeDelegate = self
        mailer.setToRecipients([email])
        mailer.setSubject("Logbook")
        mailer.setMessageBody("Your logbook is attached as a PDF.", isHTML: false)
        mailer.addAttachmentData(pdf as Data, mimeType: "application/pdf", fileName: "Logbook.pdf")
        
        if secondaryPdf != nil {
            mailer.addAttachmentData(secondaryPdf!, mimeType: "application/pdf", fileName: "Night Logbook.pdf")
        }
        
        present(mailer, animated: true, completion: nil)
    }
    
    func exportWithPrinter(_ pdf: NSData) {
        guard UIPrintInteractionController.isPrintingAvailable else {
            showPrintingNotAvailableAlert()
            
            return
        }
        
        let printer = UIPrintInteractionController.shared
        
        let options = UIPrintInfo(dictionary: nil)
        
        options.jobName = "Logbook"
        options.outputType = .general
        options.duplex = .none
        options.orientation = .landscape
        
        printer.printingItem = pdf
        printer.printInfo = options
        
        if secondaryPdf != nil { printer.printingItems = [pdf, secondaryPdf!] }
        
        printer.present(animated: true, completionHandler: nil)
    }
}

// MARK: Mail Delegate

extension DashboardController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
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
        return -20
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
        
        dayTotalTime.text = day.duration(in: [.hour, .minute])
        
        nightTotalTime.text = night.duration(in: [.hour, .minute])
        
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
        
        let dayMax = Int(dayProgressBar.maxValue).convert(from: .second, to: .hour)
        
        let nightMax = Int(nightProgressBar.maxValue).convert(from: .second, to: .hour)
        
        dayHoursRequiredLabel.text = String(dayMax)
        
        nightHoursRequiredLabel.text = String(nightMax)
        
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

// MARK: BEM Check Box Delegate

extension DashboardController: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        let index = checkBox.tag
        
        let task = tasks[index]
        
        if let handler = task.checkBoxHandler {
            handler(checkBox.on)
            
            reloadTasks(animated: true)
            
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
        let deadline = DispatchTime.now() + .seconds(1)
        
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            guard self.lastRoute != nil else {
                self.lastRouteCard.isHidden = true

                return
            }

            self.lastRouteCard.isHidden = false
            self.mapView.isHidden = false

            self.setupLastRouteCard()
        }
    }

    func setupLastRouteCard() {
        lastRouteTimeLabel.text = lastRoute!.totalTimeInterval.duration()
        
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
