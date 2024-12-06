//
//  MapViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/15/24.
//

import UIKit
import MapKit
import CoreLocation
import GEOSwift
import FirebaseAuth
import FirebaseFirestore

protocol LocationUnlocker {
    func unlockLocation(locationName: String)
}

class CustomMarker: MKPointAnnotation {
    var isVisible: Bool = false
    var isUnlocked: Bool = false
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, LocationUnlocker {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var atlasMap: MKMapView!
    
    var testPathIndex = 0
    var timer: Timer?
    var polyOverlay: MKPolygon? // for updating UTs overlay
    let manager = CLLocationManager() // start and stop location operations
    var pathFormed = false
    var routeOverlay: MKOverlay?
    var markerRefVisual: MKMarkerAnnotationView? // too many references to try and update the same map marker
    var markerRef: CustomMarker? // I only wanted to update the .glyphImage and .isUnlocked so I can quickly determine if I need to change .glyphTimage based on the result of .isUnlocked, however they are different types, There has to be a better solution man
    var selectedLocation: CustomMarker? // To hold the currently selected marker for locationinfoViewController
    var testPath: [CLLocation] = []
    let startPoint = CLLocation(latitude: 30.29194, longitude: -97.74113)
    let utLoc = CLLocation(latitude: 30.286236060447308, longitude: -97.739378471749)
    
    private var lastLocation: CLLocation? // for simulation purposes, can be deleted later
    
    var annotations: [CustomMarker] {
        return pointsOfInterest.map { point in
            let annotation = CustomMarker()
            annotation.coordinate = point.coordinate
            annotation.title = point.title
            return annotation
        }
    }
    
    var userUnlockedLocations: [String] = []
    
    // might need to use a hashmap
    var MKutLocRegion: MKPolygon?
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
            CLLocationCoordinate2D(latitude: 30.28235, longitude: -97.74199),
            CLLocationCoordinate2D(latitude: 30.29194, longitude: -97.74113)
            // More as we go just the general area for now
        ]
    
    private var holes: [MKPolygon] = [] // for hole(s) in the overlay
    
    // remember happens only once before the view loads in
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            // Update the username field (or any other field you want)
            userRef.getDocument { (document, error) in
                if let error = error {
                    print("Error fetching document: \(error)")
                } else {
                    if let document = document, document.exists {
                        // Get the array from the document
                        if let locationsList = document.get("locations") as? [String] {
                            // Loop through the array
                            print("Locations: \(locationsList)")
                            self.userUnlockedLocations = locationsList
                            print("actual array: \(self.userUnlockedLocations)")
                        } else {
                            print("No array found in the document.")
                        }
                    } else {
                        print("Document does not exist.")
                    }
                }
            }
        }
        
        manager.desiredAccuracy = kCLLocationAccuracyBest // Battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        atlasMap.delegate = self
        atlasMap.showsUserLocation = true  // Show the blue dot for user location
        atlasMap.userTrackingMode = .follow
        atlasMap.pointOfInterestFilter = .excludingAll // removes all default POIs (PointsOfInterest)
        
        // Uncomment to see all Map Markers (our own POIs)
//        for annotation in annotations {
//            atlasMap.addAnnotation(annotation)
//        }
        
        // make the entire fillIn only once
        polyOverlay = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count)
        MKutLocRegion = polyOverlay // will be used to check boundaries later
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
            rend.fillColor = UIColor.gray.withAlphaComponent(0.65)
            rend.lineWidth = 2.0  // setting width
            return rend
        }
        
        if let polyline = overlay as? MKPolyline {
            let rend = MKPolylineRenderer(polyline: polyline)
            rend.strokeColor = .blue
            rend.lineWidth = 5.0
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
        let polyRend = MKPolygonRenderer(polygon: MKutLocRegion!)
        let point = MKMapPoint(location.coordinate)
        let polyViewPoint = polyRend.point(for: point)
        
        // ************** For Demo purposes only can be deleted later **************
        if let lastLocation = lastLocation {
            let distance = lastLocation.distance(from: location)
            if distance > 500 { // Threshold for detecting a major change (500 meters)
                print("Significant location change detected. Resetting route.")
                atlasMap.removeOverlay(routeOverlay ?? MKPolyline())
                routeOverlay = nil
                pathFormed = false // Allow new route generation
            }
        }
        lastLocation = location
        // *************************************************************************
        
        if !polyRend.path.contains(polyViewPoint) {
            if !pathFormed {
                giveDirections(from: location)
                pathFormed = true
                print("Route to campus has been made")
            }
        } else {
            if pathFormed {
                // seems a wee bit choppy but it works, removes route once user arrives
                atlasMap.removeOverlay(routeOverlay!)
                routeOverlay = nil
                pathFormed = false
                print("Route to campus has terminated")
            }
            updateOverlay(for: location)
        }
        
        // might be inefficient, could maybe use a search
        for marker in annotations {
            let markerPoint = MKMapPoint(marker.coordinate)
            if !atlasMap.annotations.contains(where: { $0.title == marker.title }) && !marker.isVisible && !marker.isUnlocked && point.distance(to: markerPoint) <= 20  { // 20 meters
                atlasMap.addAnnotation(marker)
                marker.isVisible = true
                print("we added another marker")
            }
        }
    }
    
    
    // In the future I want this to look more unique, custom alert with design
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        , marker.isVisible
//        view.annotation?.title
            
        
        guard let annotationTitle = view.annotation?.title else { return }
        guard let markerView = view as? MKMarkerAnnotationView, let marker = annotations.first(where: { $0.title == annotationTitle }) else { return }
        
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let userRef = db.collection("users").document(user.uid)
//            
//            // Update the username field (or any other field you want)
//            userRef.getDocument { (document, error) in
//                if let error = error {
//                    print("Error fetching document: \(error)")
//                } else {
//                    if let document = document, document.exists {
//                        // Get the array from the document
//                        if let locationsList = document.get("locations") as? [String] {
//                            // Loop through the array
//                            for location in locationsList {
//                                if (location == annotationTitle) {
//                                    marker.isUnlocked = true
//                                    print("Location: \(location)")
//                                    break
//                                }
//                            }
//                        } else {
//                            print("No array found in the document.")
//                        }
//                    } else {
//                        print("Document does not exist.")
//                    }
//                }
//                
//                if (marker.isUnlocked) {
//                    print("PerformSegue")
//                    self.performSegue(withIdentifier: "LocationInfoSegue", sender: self)
//                } else {
//                    
//                    self.markerRefVisual = markerView
//                    self.markerRef = marker
//                    self.selectedLocation = marker
//                    let alert = UIAlertController(
//                        title: "Unknown Location Found!",
//                        message: "Play a mini game to unlock this map marker? :)",
//                        preferredStyle: .alert
//                    )
//                    
//                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
//                        self.performSegue(withIdentifier: "ShowMiniGame", sender: self)
//                    }))
//                    
//                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
//                    
//                    self.present(alert, animated: true, completion: nil)
//                    
//                }
//            }
//        } else {
//            print("couldn't authenticate user")
//        }
        
        for location in userUnlockedLocations {
            if location == annotationTitle {
                marker.isUnlocked = true
            }
        }
        
        selectedLocation = marker
        
        if (marker.isUnlocked || (annotationTitle != "UT Tower, Main Building" && annotationTitle != "The Littlefield Fountain") && annotationTitle != "Darrell K Royal–Texas Memorial Stadium") {
            print("PerformSegue")
            performSegue(withIdentifier: "LocationInfoSegue", sender: self)
        } else {
            
            markerRefVisual = markerView
            markerRef = marker
            let alert = UIAlertController(
                title: "Unknown Location Found!",
                message: "Play a mini game to unlock this map marker? :)",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "ShowMiniGame", sender: self)
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMiniGame",
           let destinationVC = segue.destination as? MiniGameViewController,
           let selectedLocation = selectedLocation {
            destinationVC.delegate = self
            destinationVC.locationTitle = selectedLocation.title ?? "Unknown"
            destinationVC.gameLocation = selectedLocation.title ?? "Unknown"
            destinationVC.locationCoordinates = selectedLocation.coordinate
            if (selectedLocation.title == "UT Tower, Main Building") {
                destinationVC.gameInstructions = "You will have 60 seconds to complete 3 rounds of finding the hidden UT Tower amongst similar objects. Press the play button to begin!"
                destinationVC.hints = ["Round 1: Look for the disco ball.", "Round 2: Look for the horse.", "Round 3: Look around the baby doll head."]
                destinationVC.hintCount = 3
                destinationVC.totalHints = 3
            } else if (selectedLocation.title == "The Littlefield Fountain") {
                destinationVC.gameInstructions = "You will have 30 seconds to correctly answer 3 trivia questions about The Littlefield Fountain. Press the play button to begin!"
                destinationVC.hints = ["There are no hints for this game."]
                destinationVC.hintCount = 1
                destinationVC.totalHints = 1
                destinationVC.timeLeft = 30
                
            } else if (selectedLocation.title == "Darrell K Royal–Texas Memorial Stadium") {
                destinationVC.gameInstructions = "You will have 15 seconds to clean up the UT Stadium. Drag all trash items onto the trash can. Press the play button to begin!"
                destinationVC.hints = ["There are no hints for this game."]
                destinationVC.hintCount = 1
                destinationVC.totalHints = 1
                destinationVC.timeLeft = 15
            }
        } else if segue.identifier == "LocationInfoSegue",
          let destinationVC = segue.destination as? LocationInfoViewController {
                    //, let selectedLocation = selectedLocation {
            
            // ADD PREP FOR SEGUE
            
//            if let locationCoordinates = locationCoordinates {
//                destinationVC.coordinates = Coordinate(locationCoordinates)
//                print("Passing coordinates: \(locationCoordinates)")
//            } else {
//                print("locationCoordinates is nil")
//            }
            print("preparing info segue")
            print("loc name: \(self.selectedLocation?.title)")
            destinationVC.delegate = self
            destinationVC.coordinates = Coordinate(self.selectedLocation!.coordinate)
            
            destinationVC.locationTitle = self.selectedLocation!.title ?? "Unknown"
//            destinationVC.locationCoordinates = selectedLocation.coordinate
//            print("Passing locationTitle: \(locationTitle)")
        }
        
    }

    
    private func updateOverlay(for location: CLLocation) {
        atlasMap.removeOverlay(polyOverlay!)
        var circle = createGEOSwiftCircle(center: location.coordinate, radius: 20)
        
        // MKutLocRegion needs to form a complete polygon, remember that, it needs to end with the same starting coordinate
        // That was the issue before, so I needed to add it in for MKutLocRegion, which has no affect on MKPolygon creation
        // But without it would error for GEOSwift Polygon because it won't be a closed polygon.
        if polyOverlay != nil, let geometry = try? circle.intersection(with: convertToGEOSwiftPolygon(mkPolygon: polyOverlay!)!) {
            switch geometry {
            case .polygon(let polygon):
                circle = polygon
            default: break
            }
        }
        
        // Find intersecting polygons from `holes`
        let intersectingHoles = findIntersectingPolygons(for: circle)
        
        // Unionize intersecting polygons if found
        if !intersectingHoles.isEmpty {
            let unionizedPolygon = performUnion(for: circle, with: intersectingHoles)
            // Replace intersecting holes with the new unionized polygon
            holes.removeAll { intersectingHoles.contains($0) }
            holes.append(unionizedPolygon)
        } else {
            // If no intersections, add as disjoint
            let Mkcircle = convertGEOSwiftGeometryToMKPolygon(geoswiftGeometry: .polygon(circle))
            holes.append(Mkcircle!)
        }
        
        // Recreate the overlay with updated `holes`
        polyOverlay = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count, interiorPolygons: holes)
        atlasMap.addOverlay(polyOverlay!)
    }
    
    // Return MKPolygon list of intersections
    private func findIntersectingPolygons(for polygon: Polygon) -> [MKPolygon] {
        return holes.filter { hole in
            // Convert MKPolygon to GEOSwift Polygon for intersection check
            guard let geoswiftHole = convertToGEOSwiftPolygon(mkPolygon: hole) else { return false }
            
            do {
                let intersection = try polygon.intersects(geoswiftHole)
                return intersection
            } catch {
                print("Error finding intersection between Polygons: \(error)")
                return false
            }
        }
    }
    
    // In the future I need to optimize this so we stop making conversions all the time
    // This helps with MKPolygon-to-Polygon creation
    private func convertToGEOSwiftPolygon(mkPolygon: MKPolygon) -> Polygon? {
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: mkPolygon.pointCount)
        mkPolygon.getCoordinates(&coordinates, range: NSRange(location: 0, length: mkPolygon.pointCount))
        // Convert MKPolygon CLLocationCoordinate2D to GEOSwift Points
        let geoswiftCoordinates = coordinates.map { Point(x: $0.longitude, y: $0.latitude) }
        
        // Will try to create a Polygon using the geoswiftcoordinates
        do {
            let boundary = try Polygon.LinearRing(points: geoswiftCoordinates)
//            print("We successfully made the polygon")
            return Polygon(exterior: boundary)
        } catch {
            print("Error creating GEOSwift Polygon: \(error)")
            return nil
        }
    }

    // This gotta be one of worst methods I ever made but we keep er' goin
    private func performUnion(for polygon: Polygon, with intersectingHoles: [MKPolygon]) -> MKPolygon {
        // store formed Geometry (any Point, Polygon, Multigon, etc)
        var combinedPolygon: Geometry = .polygon(polygon)
        
        // for every hole we found that intersects Polygon, perform a union
        for hole in intersectingHoles {
            // conversion from MK to GEOSwift, absolutely disgusting
            let polygon2 = convertToGEOSwiftPolygon(mkPolygon: hole)
            
            // perform the union, gives back geometry, update the combinedPolygon
            if let union = try? combinedPolygon.union(with: polygon2!) {
                combinedPolygon = union
            }
        }
        
        // turn this bad boy into an MKPolygon, again these conversions are disgusting I am sorry
        return convertGEOSwiftGeometryToMKPolygon(geoswiftGeometry: combinedPolygon)!
    }
    
    func createGEOSwiftCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, numPoints: Int = 100) -> Polygon {
        var points: [Point] = []
        
        let eRad = 6371000.0  // Earth radius in meters
        
        for i in 0..<numPoints {
            let angle = (Double(i) / Double(numPoints)) * 2 * Double.pi  // Angle in radians
            let latOffset = (radius / eRad) * cos(angle) * (180.0 / .pi)
            let lonOffset = (radius / eRad) * sin(angle) * (180.0 / .pi) / cos(center.latitude * .pi / 180.0)
            
            let point = Point(x: center.longitude + lonOffset, y: center.latitude + latOffset)
            points.append(point)
        }
        
        points.append(points[0])
        
        // Return a GEOSwift Polygon from the points
        do {
            let linearRing = try Polygon.LinearRing(points: points)
            let geoswiftCircle = Polygon(exterior: linearRing)
            return geoswiftCircle
        } catch {
            fatalError("Error creating GEOSwift Polygon: \(error)")
        }
    }
    
    func convertGEOSwiftGeometryToMKPolygon(geoswiftGeometry: Geometry) -> MKPolygon? {
        switch geoswiftGeometry {
        case .polygon(let polygon):
            // If it's a single Polygon, convert it to MKPolygon
            let coordinates = polygon.exterior.points.map { point in
                CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
            }
            return MKPolygon(coordinates: coordinates, count: coordinates.count)
            
        case .multiPolygon(let multiPolygon):
            // If it's a MultiPolygon, handle each polygon individually
            var allCoordinates: [CLLocationCoordinate2D] = []
            for geoPolygon in multiPolygon.polygons {
                let coordinates = geoPolygon.exterior.points.map { point in
                    CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
                }
                allCoordinates.append(contentsOf: coordinates)
            }
            return MKPolygon(coordinates: allCoordinates, count: allCoordinates.count)
            
        default:
            // If it's not a polygon or multiPolygon, return nil
            return nil
        }
    }
    
    // I need to track the users location, if they are near the campus, great! No need for rediraction to the place, otherwise give some directions
    private func setMapLocation(location: CLLocation) {
        // the combined lat and long, needed for MKCoordinateSpan as a CLLocationCoordinate2D parameter for center:
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // How much of a birds eye view do we want to show for the latitude and longitude
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        // will be the coordinate and span graphic region visualized
        let region = MKCoordinateRegion(center: coordinate, span: span)
        atlasMap.setRegion(region, animated: true)
    }
    
    private func giveDirections(from location: CLLocation) {
        // If there's already an overlay, remove it before creating a new one
        if let overlay = routeOverlay {
            atlasMap.removeOverlay(overlay)
            routeOverlay = nil
        }
        
        let directionReq = MKDirections.Request() // requesting directions to then provide directions back to the user
        let userMarker = MKPlacemark(coordinate: location.coordinate) // using user location coordinates (CLLocationCoordinate2d) and making marker object
        let destMarker = MKPlacemark(coordinate: utLoc.coordinate) // using UT location coordinates (CLLocationCoordinate2d) and making marker object
        directionReq.source = MKMapItem(placemark: userMarker) // setting request source to user marker object
        directionReq.destination = MKMapItem(placemark: destMarker) // setting request destination to destination marker object
        directionReq.transportType = .walking // Will show the path for walking
        
        let directions = MKDirections(request: directionReq)
        directions.calculate { (response, error) in
            if let error = error {
                print("Walking directions failed: \(error.localizedDescription)")
                directionReq.transportType = .automobile
                let fallbackDirections = MKDirections(request: directionReq)
                fallbackDirections.calculate { (fallbackResponse, fallbackError) in
                    guard let fallbackResponse = fallbackResponse else {
                        if let fallbackError = fallbackError {
                            print("Automobile directions also failed: \(fallbackError.localizedDescription)")
                        }
                        return
                    }
                    
                    self.displayRoute(response: fallbackResponse)
                }
                return
            }
            self.displayRoute(response: response!)
        }
    }
    
    private func displayRoute(response: MKDirections.Response) {
        let route = response.routes[0] // Choose the first path
        self.routeOverlay = route.polyline
        self.atlasMap.addOverlay(route.polyline, level: .aboveRoads) // Add path to the map
        let mapRegion = route.polyline.boundingMapRect // Fit the route in the map view
        self.atlasMap.setVisibleMapRect(mapRegion, animated: true) // Show the route visually
    }
    
    private func isCoordinateInsideCampus(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let fillIn = MKPolygon(coordinates: utLocRegion, count: utLocRegion.count)
        let mapPoint = MKMapPoint(coordinate)

        return fillIn.boundingMapRect.contains(mapPoint)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomMarker"
        
        guard let annotationTitle = annotation.title else { return nil }
        // Ensure we're dealing with MKPointAnnotation
        guard let pointAnnotation = annotations.first(where: { $0.title == annotationTitle }) else {
            return nil // If no matching CustomMarker is found, return nil
        }
        
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let userRef = db.collection("users").document(user.uid)
//            
//            // Update the username field (or any other field you want)
//            userRef.getDocument { (document, error) in
//                if let error = error {
//                    print("Error fetching document: \(error)")
//                } else {
//                    if let document = document, document.exists {
//                        // Get the array from the document
//                        if let locationsList = document.get("locations") as? [String] {
//                            // Loop through the array
//                            for location in locationsList {
//                                if (location == annotationTitle) {
//                                    pointAnnotation.isUnlocked = true
//                                    print("Location: \(location)")
//                                    break
//                                }
//                            }
//                        } else {
//                            print("No array found in the document.")
//                        }
//                    } else {
//                        print("Document does not exist.")
//                    }
//                }
//
//                
//                print("point annotation unlocked: \(pointAnnotation.isUnlocked)")
//                
//                if pointAnnotation.isUnlocked {
//                    print("marker nil")
//                    return
//                }
//                
//                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
//                if annotationView == nil {
//                    annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                    annotationView?.canShowCallout = true
//                    
//                }
//                
//                annotationView?.glyphImage = UIImage(systemName: "lock.fill")
//
//                // Set the marker color dynamically based on the annotation
//                if let point = pointsOfInterest.first(where: { $0.title == pointAnnotation.title }) {
//                    annotationView?.markerTintColor = point.color // Set marker color from pointsOfInterest
//                }
//                
//            }
//            
////            fetchUserLocations(userRef: userRef, locationName: annotationTitle!) { isUnlocked in
////                
////                locationUnlocked = isUnlocked
////                
////            }
//        } else {
//            print("couldn't authenticate user")
//        }
        
//        pointAnnotation.isUnlocked = locationUnlocked
//        
//        print("point annotation unlocked: \(pointAnnotation.isUnlocked)")
//        
        
        for location in userUnlockedLocations {
            if location == annotationTitle {
                pointAnnotation.isUnlocked = true
            }
        }
        
//        if pointAnnotation.isUnlocked {
//            print("marker nil")
//            return nil
//        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        }
        
        if !pointAnnotation.isUnlocked {
            annotationView?.glyphImage = UIImage(systemName: "lock.fill")
        }

        // Set the marker color dynamically based on the annotation
        if let point = pointsOfInterest.first(where: { $0.title == pointAnnotation.title }) {
            annotationView?.markerTintColor = point.color // Set marker color from pointsOfInterest
        }

        return annotationView
    }
    
    func fetchUserLocations(userRef: DocumentReference, locationName: String, completion: @escaping (Bool) -> Void) {
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(false) // Handle error case
            } else {
                if let document = document, document.exists {
                    // Get the array from the document
                    if let locationsList = document.get("locations") as? [String] {
                        // Check if the annotation title exists in the array
                        for location in locationsList {
                            if location == locationName {
                                print("true returned")
                                completion(true)  // Marker unlocked, return true
                                return
                            }
                        }
                        completion(false)  // Marker not unlocked
                    } else {
                        print("No array found in the document.")
                        completion(false)  // No locations found, return false
                    }
                } else {
                    print("Document does not exist.")
                    completion(false)  // Document not found
                }
            }
        }
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "HamburgerMenuStoryboard", bundle: nil)
        let popUpMenu = storyboard.instantiateViewController(withIdentifier: "MenuPopUp") as? MenuPopUpViewController
        
        let menuHeight = CGFloat(252) //self.view.frame.height / 3.7
        popUpMenu!.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: menuHeight)
        
        addChild(popUpMenu!)
        view.addSubview(popUpMenu!.view)
        popUpMenu!.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.3, animations: {
            popUpMenu!.view.frame.origin.y = self.view.frame.height - menuHeight
        })
    }
    
    // Unwind back to this instance of the map
    @IBAction func unwindToMapViewController(segue: UIStoryboardSegue) {
        if let marker = markerRef, !marker.isUnlocked {
            markerRefVisual?.glyphImage = nil
            marker.isUnlocked = true
        }
    }
    
    func unlockLocation(locationName: String) {
        if !userUnlockedLocations.contains(locationName) {
            userUnlockedLocations.append(locationName)
            
            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(user.uid)
                
                // Update the username field (or any other field you want)
                userRef.updateData([
                    "score": FieldValue.increment(Int64(1))
                ]) { error in
                    if let error = error {
                        print("Error updating user data: \(error.localizedDescription)")
                    } else {
                        print("Score incremented by 1")
                    }
                }
            } else {
                print("couldn't authenticate user")
            }
        }
    }
    
}

// I wanna go to bed and dream about flying monkeys
