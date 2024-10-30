//
//  MapViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/15/24.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var atlasMap: MKMapView!
    var polyOverlay: MKPolygon? // for updating UTs overlay
    let manager = CLLocationManager() // start and stop location operations
    let utLoc = CLLocation(latitude: 30.2850, longitude: -97.7354)
    let utLocRegion = [
            CLLocationCoordinate2D(latitude: 30.29194, longitude: -97.74113),
            CLLocationCoordinate2D(latitude: 30.29166, longitude: -97.73657),
            CLLocationCoordinate2D(latitude: 30.29159, longitude: -97.73531),
            CLLocationCoordinate2D(latitude: 30.29128, longitude: -97.73501),
            CLLocationCoordinate2D(latitude: 30.29060, longitude: -97.73459),
            CLLocationCoordinate2D(latitude: 30.29041, longitude: -97.73452),
            CLLocationCoordinate2D(latitude: 30.29031, longitude: -97.73451),
            CLLocationCoordinate2D(latitude: 30.29017, longitude: -97.73451),
            CLLocationCoordinate2D(latitude: 30.28926, longitude: -97.73465),
            CLLocationCoordinate2D(latitude: 30.28908, longitude: -97.73274),
            CLLocationCoordinate2D(latitude: 30.28916, longitude: -97.73104),
            CLLocationCoordinate2D(latitude: 30.28881, longitude: -97.72980),
            CLLocationCoordinate2D(latitude: 30.28824, longitude: -97.72918),
            CLLocationCoordinate2D(latitude: 30.28801, longitude: -97.72885),
            CLLocationCoordinate2D(latitude: 30.28720, longitude: -97.72713),
            CLLocationCoordinate2D(latitude: 30.28711, longitude: -97.72682),
            CLLocationCoordinate2D(latitude: 30.28316, longitude: -97.72797),
            CLLocationCoordinate2D(latitude: 30.28246, longitude: -97.72863),
            CLLocationCoordinate2D(latitude: 30.28105, longitude: -97.72961),
            CLLocationCoordinate2D(latitude: 30.27964, longitude: -97.73106),
            CLLocationCoordinate2D(latitude: 30.27910, longitude: -97.73250),
            CLLocationCoordinate2D(latitude: 30.28173, longitude: -97.74191),
            CLLocationCoordinate2D(latitude: 30.28235, longitude: -97.74199)
            // More as we go just the general area for now
        ]
    
    private var holes: [MKPolygon] = [] // for hole(s) in the overlay
    
    // remember happens only once before the view loads in
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest // Battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        atlasMap.delegate = self
        atlasMap.showsUserLocation = true  // Show the blue dot for user location
        atlasMap.userTrackingMode = .follow
        atlasMap.pointOfInterestFilter = .excludingAll // removes all default POIs (PointsOfInterest)
        
        // make the entire fillIn only once
        polyOverlay = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count) // great but I want a circle damnit
        atlasMap.addOverlay(polyOverlay!)
        
        let buttonSize: CGFloat = 30
        menuButton.frame = CGRect(x: self.view.frame.width - 65, y: self.view.frame.height - 65, width: buttonSize, height: buttonSize)


    }
    
    // this happens every time the view has appeared on the screen, it is reoccuring
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.startUpdatingLocation() // fetches location
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let pOverlay = overlay as? MKPolygon {
            let rend = MKPolygonRenderer(polygon: pOverlay)
            
            rend.fillColor = UIColor.gray.withAlphaComponent(0.65)  // tranparentish gray, there isn't a way to change the apple maps color theme
//            rend.strokeColor = UIColor.gray  // Gray color
            rend.lineWidth = 2.0  // setting width
            return rend
        }
        return MKOverlayRenderer(overlay: overlay)  // In case of a different overlay
    }
    
    // called when we start the managers location update function line 29
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations: [CLLocation] // Array of locations as it changes
        guard let location = locations.last else { return }
        // after the most recent location grabbed
        handleLocationUpdates(location: location) // set our location on the map
    }
    
    // handles user response to location tracking
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied:
            print("Location access denied")
        default:
            break
        }
    }
    
    private func handleLocationUpdates(location: CLLocation) {
        let dist = location.distance(from: utLoc)
        
        if dist > 1609.34 { // greater than a mile? Will change this to be based around the border of the campus or the average coordinate
            giveDirections(from: location)
        } else {
            updateOverlay(for: location)
        }
    }
    
    private func updateOverlay(for location: CLLocation) {
        atlasMap.removeOverlay(polyOverlay!) // we need to remember the coordinates, all of them
        let circCoordinates = createTheCircleCoordinates(center: location.coordinate, radius: 20) // list of points for a circle
        let cutOut = MKPolygon(coordinates: circCoordinates, count: circCoordinates.count) // praying this works for the hole cutout
        holes.append(cutOut) // add the polygon, but this means we have to do a ton of managing, stress testing all that jive
        
        // I need to be able to extract the intersection points and modify the circleCoordinates
        let coor = CLLocationCoordinate2D(latitude: 30.28825, longitude: -97.73763)
        let circCoordinates2 = createTheCircleCoordinates(center: coor, radius: 20) // list of points for a circle
        let cutOut2 = MKPolygon(coordinates: circCoordinates2, count: circCoordinates2.count) // praying this works for the hole cutout
        holes.append(cutOut2)
        
        polyOverlay = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count, interiorPolygons: holes) // Exclude interior
        atlasMap.addOverlay(polyOverlay!)
    }
    
    // function to convert circle to coordinates, this will be for the hole
    func createTheCircleCoordinates(center: CLLocationCoordinate2D, radius: CLLocationDistance, numPoints: Int = 100) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let eRad = 6371000.0
        
        for i in 0..<numPoints {
            let angle = (Double(i) / Double(numPoints)) * 2 * Double.pi  // Angle in radians
            let latOffset = (radius / eRad) * cos(angle) * (180.0 / .pi)
            let lonOffset = (radius / eRad) * sin(angle) * (180.0 / .pi) / cos(center.latitude * .pi / 180.0)

            let point = CLLocationCoordinate2D(
                latitude: center.latitude + latOffset,
                longitude: center.longitude + lonOffset
            )
            coordinates.append(point)
        }
        return coordinates
    }
    
    // I need to track the users location, if they are near the campus, great! No need for rediraction to the place
    // If they are far away from it, more than a mile from the boarder of the campus site (set by us), give some directions
    private func setMapLocation(location: CLLocation) {
        // the combined lat and long, needed for MKCoordinateSpan as a CLLocationCoordinate2D parameter for center:
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        // we could instead just put location.coordinate for the center:
        // But this was just to show newcomers
        
        // How much of a birds eye view do we want to show for the latitude and longitude
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        // will be the coordinate and span graphic region visualized
        let region = MKCoordinateRegion(center: coordinate, span: span)
        atlasMap.setRegion(region, animated: true)
    }
    
    private func giveDirections(from location: CLLocation) {
        let directionReq = MKDirections.Request() // requesting directions to then provide directions back to the user
        let userMarker = MKPlacemark(coordinate: location.coordinate) // using user location coordinates (CLLocationCoordinate2d) and making marker object
        let destMarker = MKPlacemark(coordinate: utLoc.coordinate) // using UT location coordinates (CLLocationCoordinate2d) and making marker object
        directionReq.source = MKMapItem(placemark: userMarker) // setting request source to user marker object
        directionReq.destination = MKMapItem(placemark: destMarker) // setting request destination to destination marker object
        directionReq.transportType = .automobile // Will show the path for drivers
        
        let directions = MKDirections(request: directionReq)
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("Issue with making the directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0] // choose the first path and call it a day
            self.atlasMap.addOverlay(route.polyline, level: .aboveRoads) // shows the path on the map
            
            let mapRegion = route.polyline.boundingMapRect // fit entire route on the map
            self.atlasMap.setVisibleMapRect(mapRegion, animated: true) // finally show it visably
        }
    }
    
    private func isCoordinateInsideCampus(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let fillIn = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count)
        let mapPoint = MKMapPoint(coordinate)

        return fillIn.boundingMapRect.contains(mapPoint)
    }
    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HamburgerMenuStoryboard", bundle: nil)
        let popUpMenu = storyboard.instantiateViewController(withIdentifier: "MenuPopUp") as? MenuPopUpViewController
        
        let menuHeight = self.view.frame.height / 4.5
        popUpMenu!.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: menuHeight)
        
        addChild(popUpMenu!)
        view.addSubview(popUpMenu!.view)
        popUpMenu!.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.3, animations: {
            popUpMenu!.view.frame.origin.y = self.view.frame.height - menuHeight
        })

    }
}


// I wanna go to bed
