
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
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupRouteCard()
    }
    
    // MARK: Actions
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        TripStore.add(trip)
        
        Keychain.shared.setData(locations, for: .lastRoute)
        
        cacheOdometer()
        
        tabBarController!.selectedIndex = 0
        
        navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        showCancelAlert()
    }
    
    func cacheOdometer() {
        let odometer =  (Cache.shared.getOdometer(for: trip.car) ?? 0)
        
        let distance = Int(trip.distance / (kmToMeters: 1000))
        
        Cache.shared.set(odometer: (odometer + distance), for: trip.car)
        
        Cache.shared.save()        
    }
    
    func setupRouteCard() {
        totalTimeLabel.text = trip.totalTime.time()
        
        totalDistanceLabel.text = trip.distance.distance()
        
        setupMapView()
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
