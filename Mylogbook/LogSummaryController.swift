
import CoreLocation
import MapKit
import PopupDialog
import UIKit

class LogSummaryController: UIViewController {
    
    var trip: Trip!
    
    var locations: [CLLocation]!
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    @IBOutlet weak var carTypeImage: UIImageView!
    @IBOutlet weak var carNameLabel: UILabel!
    
    @IBOutlet weak var supervisorAvatar: UIImageView!
    @IBOutlet weak var supervisorNameLabel: UILabel!
    
    @IBOutlet weak var startLocationTextField: UITextField!
    @IBOutlet weak var endLocationTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupResourceCards()
        
        setupRouteCard()
        
        setupTripItems(in: view)
    }
    
    // MARK: Actions
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        save()
        
        tabBarController!.selectedIndex = 0
        
        navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        showCancelAlert()
    }
    
    func didChangeTextField(_ sender: UITextField) {
        let maxLength = 50
        
        if let text = sender.text, text.characters.count >= maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            
            sender.text = text.substring(to: index)
        }
        
        validate()
    }
    
    // MARK: Save
    
    func save() {
        saveLocations()
        
        TripStore.add(trip)
        
        saveLastRoute()
        
        cacheOdometer()
    }
    
    func saveLocations() {
        trip.startLocation = startLocationTextField.text!
        trip.endLocation = endLocationTextField.text!
    }
    
    func saveLastRoute() {
        let lastRoute = LastRoute(startedAt: trip.startedAt,
                                  endedAt: trip.endedAt,
                                  locations: locations,
                                  distance: trip.distance)
        
        Keychain.shared.setData(lastRoute, for: .lastRoute)
    }
    
    func cacheOdometer() {
        let odometer =  (Cache.shared.getOdometer(for: trip.car) ?? 0)
        
        let distance = Int(trip.distance / (kmToMeters: 1000))
        
        Cache.shared.set(odometer: (odometer + distance), for: trip.car)
        
        Cache.shared.save()        
    }
    
    // MARK: Cards
    
    func setupResourceCards() {
        carNameLabel.text = trip.car.name
        carTypeImage.image = trip.car.image(ofSize: .display)
        
        supervisorNameLabel.text = trip.supervisor.name
        supervisorAvatar.image = trip.supervisor.image(ofSize: .display)
    }
    
    func setupRouteCard() {
        startLocationTextField.text = trip.startLocation
        endLocationTextField.text = trip.endLocation
        
        startLocationTextField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
        endLocationTextField.addTarget(self, action: #selector(didChangeTextField(_:)), for: .editingChanged)
        
        totalTimeLabel.text = trip.totalTimeInterval.duration()
        totalDistanceLabel.text = trip.distance.distance()
        
        setupMapView()
    }
    
    // MARK: Validation
    
    func validate() {
        let isTripConditionsValid = !trip.weather.isEmpty   &&
                                    !trip.roads.isEmpty     &&
                                    !trip.traffic.isEmpty
        
        let isLocationsValid = startLocationTextField.text != nil        &&
                               !startLocationTextField.text!.isEmpty     &&
                               endLocationTextField.text != nil          &&
                               !endLocationTextField.text!.isEmpty
        
        saveButton.isEnabled = isTripConditionsValid && isLocationsValid
    }
}

// MARK: Alerting

extension LogSummaryController: Alerting {
    func showCancelAlert() {
        let title = "Cancel Recording"
        
        let message = "Are you sure? Progress will be lost."
        
        let noButton = CancelButton(title: "NO", action: nil)
        
        let yesButton = DefaultButton(title: "YES") {
            self.navigationController!.popToRootViewController(animated: true)
        }
        
        showAlert(title: title, message: message, buttons: [noButton, yesButton])
    }
}

// MARK: Trip Item delegate

extension LogSummaryController: TripItemDelegate {
    func setupTripItems(in view: UIView) {
        for subview in view.subviews {
            if let tripItem = subview as? TripItem {
                tripItem.delegate = self
            }
            
            setupTripItems(in: subview)
        }
    }
    
    func didChangeTripItem(_ value: Bool, title: String) {
        if let condition = Weather(rawValue: title) {
            trip.set(value, for: .weather(condition))
        }

        if let condition = Traffic(rawValue: title) {
            trip.set(value, for: .traffic(condition))
        }

        if let condition = Road(rawValue: title) {
            trip.set(value, for: .road(condition))
        }
        
        validate()
    }
}

// MARK: Map View Delegate

extension LogSummaryController: MKMapViewDelegate {
    func setupMapView() {
        guard locations.count > 0 else { return }
        
        mapView.delegate = self
        
        let center = locations[(locations.count - 1) / 2].coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        
        var coordinates = locations.map { $0.coordinate }
        
        let polyline = MKPolyline(coordinates: &coordinates,
                                  count: coordinates.count)
        
        mapView.add(polyline)
        
        addAnnotations()
    }
    
    func addAnnotations() {
        let startAnnotation = MKPointAnnotation()
        
        startAnnotation.title = "Started Here"
        
        startAnnotation.subtitle = trip.startedAt.local(date: .none, time: .short)
        
        startAnnotation.coordinate = locations.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"

        endAnnotation.subtitle = trip.endedAt.local(date: .none, time: .short)
        
        endAnnotation.coordinate = locations.last!.coordinate
        
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
