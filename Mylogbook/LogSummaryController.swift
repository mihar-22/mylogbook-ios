
import CoreLocation
import MapKit
import PopupDialog
import UIKit

class LogSummaryController: UIViewController {
    
    var trip: Trip!
    
    var locations: [CLLocation]!
    
    // MARK: Outlets
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carRegistrationLabel: UILabel!
    @IBOutlet weak var carTypeImage: UIImageView!
    
    @IBOutlet weak var supervisorNameLabel: UILabel!
    @IBOutlet weak var supervisorAvatar: UIImageView!
    
    @IBOutlet weak var weatherClearImage: UIImageView!
    @IBOutlet weak var weatherClearLabel: UILabel!
    @IBOutlet weak var weatherRainImage: UIImageView!
    @IBOutlet weak var weatherRainLabel: UILabel!
    @IBOutlet weak var weatherThunderImage: UIImageView!
    @IBOutlet weak var weatherThunderLabel: UILabel!
    @IBOutlet weak var weatherFogLabel: UILabel!
    @IBOutlet weak var weatherFogImage: UIImageView!
    @IBOutlet weak var weatherHailLabel: UILabel!
    @IBOutlet weak var weatherHailImage: UIImageView!
    @IBOutlet weak var weatherSnowLabel: UILabel!
    @IBOutlet weak var weatherSnowImage: UIImageView!
    
    @IBOutlet weak var trafficLightImage: UIImageView!
    @IBOutlet weak var trafficLightLabel: UILabel!
    @IBOutlet weak var trafficModerateImage: UIImageView!
    @IBOutlet weak var trafficModerateLabel: UILabel!
    @IBOutlet weak var trafficHeavyImage: UIImageView!
    @IBOutlet weak var trafficHeavyLabel: UILabel!
    
    @IBOutlet weak var roadLocalStreetImage: UIImageView!
    @IBOutlet weak var roadLocalStreetLabel: UILabel!
    @IBOutlet weak var roadMainRoadImage: UIImageView!
    @IBOutlet weak var roadMainRoadLabel: UILabel!
    @IBOutlet weak var roadFreewayImage: UIImageView!
    @IBOutlet weak var roadFreewayLabel: UILabel!
    @IBOutlet weak var roadInnerCityImage: UIImageView!
    @IBOutlet weak var roadInnerCityLabel: UILabel!
    @IBOutlet weak var roadRuralRoadImage: UIImageView!
    @IBOutlet weak var roadRuralRoadLabel: UILabel!
    @IBOutlet weak var roadGravelImage: UIImageView!
    @IBOutlet weak var roadGravelLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        setupCards()
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
        
    // MARK: Cards
    
    func setupCards() {
        setupCarCard()
        setupSupervisorCard()
        setupWeatherCard()
        setupTrafficCard()
        setupRoadsCard()
        setupRouteCard()
    }
    
    func setupCarCard() {
        let car = trip.car
        
        carNameLabel.text = car.name
        carRegistrationLabel.text = car.registration
        // set type image here
    }
    
    func setupSupervisorCard() {
        let supervisor = trip.supervisor
        
        supervisorNameLabel.text = supervisor.name
        // set avatar here
    }
    
    func setupWeatherCard() {
        configureImageSet(label: weatherClearLabel,
                          image: weatherClearImage,
                          didOccur: trip.didOccur(.weather(.clear)))
        
        configureImageSet(label: weatherRainLabel,
                          image: weatherRainImage,
                          didOccur: trip.didOccur(.weather(.rain)))
        
        configureImageSet(label: weatherThunderLabel,
                          image: weatherThunderImage,
                          didOccur: trip.didOccur(.weather(.thunder)))
        
        configureImageSet(label: weatherFogLabel,
                          image: weatherFogImage,
                          didOccur: trip.didOccur(.weather(.fog)))
        
        configureImageSet(label: weatherHailLabel,
                          image: weatherHailImage,
                          didOccur: trip.didOccur(.weather(.hail)))
        
        configureImageSet(label: weatherSnowLabel,
                          image: weatherSnowImage,
                          didOccur: trip.didOccur(.weather(.snow)))
    }
    
    func setupTrafficCard() {
        configureImageSet(label: trafficLightLabel,
                          image: trafficLightImage,
                          didOccur: trip.didOccur(.traffic(.light)))
        
        configureImageSet(label: trafficModerateLabel,
                          image: trafficModerateImage,
                          didOccur: trip.didOccur(.traffic(.moderate)))
        
        configureImageSet(label: trafficHeavyLabel,
                          image: trafficHeavyImage,
                          didOccur: trip.didOccur(.traffic(.heavy)))
    }
    
    func setupRoadsCard() {
        configureImageSet(label: roadLocalStreetLabel,
                          image: roadLocalStreetImage,
                          didOccur: trip.didOccur(.road(.localStreet)))
        
        configureImageSet(label: roadMainRoadLabel,
                          image: roadMainRoadImage,
                          didOccur: trip.didOccur(.road(.mainRoad)))
        
        configureImageSet(label: roadFreewayLabel,
                          image: roadFreewayImage,
                          didOccur: trip.didOccur(.road(.freeway)))
        
        configureImageSet(label: roadInnerCityLabel,
                          image: roadInnerCityImage,
                          didOccur: trip.didOccur(.road(.innerCity)))
        
        configureImageSet(label: roadRuralRoadLabel,
                          image: roadRuralRoadImage,
                          didOccur: trip.didOccur(.road(.ruralRoad)))
        
        configureImageSet(label: roadGravelLabel,
                          image: roadGravelImage,
                          didOccur: trip.didOccur(.road(.gravel)))
    }
    
    func setupRouteCard() {
        totalTimeLabel.text = trip.totalTime.time()
        
        totalDistanceLabel.text = trip.distance.distance()
        
        setupMapView()
    }
    
    func configureImageSet(label: UILabel, image: UIImageView, didOccur: Bool) {
        if didOccur {
            // change to checked image
            image.alpha = 1
            label.alpha = 1
        } else {
            // change to plain image
            image.alpha = 0.3
            label.alpha = 0.3
        }
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
