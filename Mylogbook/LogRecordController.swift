
import Alamofire
import CoreLocation
import MapKit
import PopupDialog
import UIKit

class LogRecordController: UIViewController {
    
    var trip: Trip!
    
    // MARK: Location
    
    var seconds = 0
    
    var distance = 0.0
    
    let desiredAccuracy = 20.0
    
    var isPositionFixed = false
    
    var isPaused = false
    
    var bestAccuracy = 1000.0
    
    var timer = Timer()
    
    var locations = [CLLocation]()
    
    var authorizationStatusWasChanged = false
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        manager.activityType = .automotiveNavigation
        
        manager.distanceFilter = 20.0
        
        manager.delegate = self
        
        return manager
    }()
    
    // MARK: Outlets
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupNavigation()

        shouldStartRecording()
    }
    
    // MARK: Actions
    
    @IBAction func didTapStop(_ sender: UIBarButtonItem) {
        guard locations.count > 1 else { return }
        
        recording(will: .stop)
        
        performSegue(withIdentifier: "stopRecordingSegue", sender: nil)
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        showCancelAlert()
    }
    
    @IBAction func didTapPause(_ sender: UIBarButtonItem) {        
        let action: RecordAction =  isPaused ? .play : .pause
        
        recording(will: action)

        let item: UIBarButtonSystemItem = isPaused ? .pause : .play
        
        setToolBar(item: item)
        
        isPaused = !isPaused
    }
    
    func openSettings(string: String) {
        self.setupApplicationObservers()

        let url = URL(string: string)!
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: Application Observer
    
    func setupApplicationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(_:)),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground(_:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: UIApplication.shared)
    }
    
    func applicationDidEnterBackground(_ notification: NSNotification) {
        authorizationStatusWasChanged = false
    }
    
    func applicationDidBecomeActive(_ notification: NSNotification) {
        guard !authorizationStatusWasChanged else { return }
        
        shouldStartRecording()
    }
    
    // MARK: Toolbar
    
    func setToolBar(item: UIBarButtonSystemItem) {
        let button = UIBarButtonItem(barButtonSystemItem: item,
                                     target: self,
                                     action: #selector(didTapPause(_:)))
        
        button.style = .done
        
        toolbar.setItems([button], animated: true)
    }
    
    // MARK: Timer
    
    func setupTimer() {
        timer.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(eachTimerInterval(_:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func eachTimerInterval(_ timer: Timer) {
        seconds += 1
        
        timeLabel.text = TimeInterval(seconds).time()
    }
    
    // MARK: Navigation
    
    func setupNavigation() {        
        navItem.setHidesBackButton(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecordingSegue" {
            if let viewController = segue.destination as? LogDetailsController {
                viewController.trip = trip
                
                viewController.locations = locations
            }
        }
    }
    
    // MARK: Recordings
    
    func recordCoordinates() {
        let startCoordinate = locations.first!.coordinate
        
        trip.startLatitude = startCoordinate.latitude.round(places: 8)
        
        trip.startLongitude = startCoordinate.longitude.round(places: 8)
        
        let endCoordinate = locations.last!.coordinate
        
        trip.endLatitude = endCoordinate.latitude.round(places: 8)
        
        trip.endLongitude = endCoordinate.longitude.round(places: 8)
    }
    
    func recordLightConditions() {
        let light = TripCalculator.calculateLightConditions(for: trip)
        
        if light.dawn { trip.light.add(Light.dawn.code) }
        if light.day { trip.light.add(Light.day.code) }
        if light.dusk { trip.light.add(Light.dusk.code) }
        if light.night { trip.light.add(Light.night.code) }
    }
}

// MARK: Alerting

extension LogRecordController: Alerting {
    func showLocationServicesDisabledAlert() {
        let title = "Turn On Location Services"
        
        let message = "Mylogbook uses your location to record the distance driven and the route taken on your trip. \n\nEnable \"Location Services\" to continue."
        
        let cancelButton = CancelButton(title: "CANCEL") { self.recording(will: .cancel) }
        
        let settingsButton = DefaultButton(title: "SETTINGS") {
            self.openSettings(string: "App-Prefs:root=Privacy&path=LOCATION")
        }
        
        showAlert(title: title, message: message, buttons: [cancelButton, settingsButton])
    }
    
    func showPermissionDeniedAlert() {
        let title = "Allow Location Access"
        
        let message = "Mylogbook uses your location to record the distance driven and the route taken on your trip. \n\nSelect \"Location -> While Using the App\" to continue."
        
        let cancelButton = CancelButton(title: "CANCEL") { self.recording(will: .cancel) }
        
        let settingsButton = DefaultButton(title: "SETTINGS") {
            self.openSettings(string: UIApplicationOpenSettingsURLString)
        }
        
        showAlert(title: title, message: message, buttons: [cancelButton, settingsButton])
    }
    
    func showCancelAlert() {
        let title = "Cancel Recording"
        
        let message = "Are you sure? Progress will be lost."
        
        let noButton = CancelButton(title: "NO", action: nil)
        
        let yesButton = DefaultButton(title: "YES") { self.recording(will: .cancel) }
        
        showAlert(title: title, message: message, buttons: [noButton, yesButton])
    }
}

// MARK: Location Manager Delegate

extension LogRecordController: CLLocationManagerDelegate {
    
    enum RecordAction {
        case play, pause, start, stop, cancel
    }
    
    func setRecordingDefaults() {
        seconds = 0
        
        distance = 0.0
        
        locations.removeAll()
    }
    
    func recording(will action: RecordAction) {
        let start = {
            self.setupTimer()
            
            self.locationManager.startUpdatingLocation()
        }

        let stop = {
            self.timer.invalidate()
            
            self.locationManager.stopUpdatingLocation()
        }
        
        switch action {
        case .play:
            start()
        case .pause:
            stop()
        case .start:
            setRecordingDefaults()
            
            start()
            
            trip.startedAt = Date()
            
            trip.timeZoneIdentifier = TimeZone.current.identifier
        case.stop:
            stop()
            
            trip.endedAt = Date()
            
            trip.distance = distance.round(places: 2)
            
            recordCoordinates()
            
            recordLightConditions()
        case .cancel:
            navigationController!.popViewController(animated: true)
        }
    }
    
    func shouldStartRecording() {
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationServicesDisabledAlert()
            
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        
        locationManager(didChangeAuthorization: status)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        locationManager(didChangeAuthorization: status)
    }
    
    func locationManager(didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatusWasChanged = true
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showPermissionDeniedAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            recording(will: .start)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        guard isPositionFixed else {
            shouldProcess(locations)
            
            return
        }
        
        locationDidUpdate(locations)
    }
    
    func shouldProcess(_ locations: [CLLocation]) {
        for location in locations {
            guard location.timestamp.timeIntervalSinceNow < 5.0 else { continue }
            
            let accuracy = location.horizontalAccuracy
            
            guard accuracy > 0 else { continue }
            
            if bestAccuracy > accuracy {
                bestAccuracy = accuracy
                
                if bestAccuracy <= desiredAccuracy { isPositionFixed = true }
            }
        }
    }
    
    func locationDidUpdate(_ locations: [CLLocation]) {
        for location in locations {
            let accuracy = location.horizontalAccuracy

            guard accuracy > 0 && accuracy <= desiredAccuracy else { continue }
            
            updateDistance(with: location)
            
            self.locations.append(location)
        }
    }
    
    func updateDistance(with location: CLLocation) {
        if locations.count > 0 {
            distance += location.distance(from: self.locations.last!)
            
            distanceLabel.text = distance.distance()
        }
    }
}
