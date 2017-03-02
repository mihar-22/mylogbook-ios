
import CoreLocation
import MapKit
import UIKit

class LogSummaryController: UIViewController {
    
    var trip: Trip!
    
    var locations: [CLLocation]!
    
    // MARK: Outlets
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var carRegistrationLabel: UILabel!
    @IBOutlet weak var carTypeImage: UIImageView!
    
    @IBOutlet weak var supervisorNameLabel: UILabel!
    @IBOutlet weak var supervisorLicenseLabel: UILabel!
    @IBOutlet weak var supervisorGenderImage: UIImageView!
    
    @IBOutlet weak var weatherClearImage: UIImageView!
    @IBOutlet weak var weatherClearLabel: UILabel!
    @IBOutlet weak var weatherRainImage: UIImageView!
    @IBOutlet weak var weatherRainLabel: UILabel!
    @IBOutlet weak var weatherThunderImage: UIImageView!
    @IBOutlet weak var weatherThunderLabel: UILabel!
    
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
    @IBOutlet weak var roadRuralHighwayImage: UIImageView!
    @IBOutlet weak var roadRuralHighwayLabel: UILabel!
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
        
        let distance = Int(trip.distance / (kmToMeters: 1000))
        
        UserSettings.shared.incrementOdometerBy(distance, for: trip.car)
        
        Keychain.shared.lastRoute = locations
        
        tabBarController!.selectedIndex = 0
        
        navigationController!.popToRootViewController(animated: true)
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
        
        supervisorNameLabel.text = supervisor.fullName
        supervisorLicenseLabel.text = supervisor.license
        // set gender image here
    }
    
    func setupWeatherCard() {
        configureImageSet(label: weatherClearLabel,
                          image: weatherClearImage,
                          didOccur: trip.clear)
        
        configureImageSet(label: weatherRainLabel,
                          image: weatherRainImage,
                          didOccur: trip.rain)
        
        configureImageSet(label: weatherThunderLabel,
                          image: weatherThunderImage,
                          didOccur: trip.thunder)
    }
    
    func setupTrafficCard() {
        configureImageSet(label: trafficLightLabel,
                          image: trafficLightImage,
                          didOccur: trip.light)
        
        configureImageSet(label: trafficModerateLabel,
                          image: trafficModerateImage,
                          didOccur: trip.moderate)
        
        configureImageSet(label: trafficHeavyLabel,
                          image: trafficHeavyImage,
                          didOccur: trip.heavy)
    }
    
    func setupRoadsCard() {
        configureImageSet(label: roadLocalStreetLabel,
                          image: roadLocalStreetImage,
                          didOccur: trip.localStreet)
        
        configureImageSet(label: roadMainRoadLabel,
                          image: roadMainRoadImage,
                          didOccur: trip.mainRoad)
        
        configureImageSet(label: roadFreewayLabel,
                          image: roadFreewayImage,
                          didOccur: trip.freeway)
        
        configureImageSet(label: roadInnerCityLabel,
                          image: roadInnerCityImage,
                          didOccur: trip.innerCity)
        
        configureImageSet(label: roadRuralHighwayLabel,
                          image: roadRuralHighwayImage,
                          didOccur: trip.ruralHighway)
        
        configureImageSet(label: roadGravelLabel,
                          image: roadGravelImage,
                          didOccur: trip.gravel)
    }
    
    func setupRouteCard() {
        totalTimeLabel.text = trip.totalTimeInterval.abbreviatedTime
        
        totalDistanceLabel.text = trip.distance.abbreviatedDistance
        
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
        
        startAnnotation.subtitle = trip.startedAt.shortTime
        
        startAnnotation.coordinate = locations.first!.coordinate
        
        let endAnnotation = MKPointAnnotation()
        
        endAnnotation.title = "Ended Here"

        endAnnotation.subtitle = trip.endedAt.shortTime
        
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
