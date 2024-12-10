import UIKit
import CoreLocation

struct PointOfInterest {
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    let title: String
}

let pointsOfInterest: [PointOfInterest] = [
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28593, longitude: -97.73941), color: .orange, title: "UT Tower, Main Building"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28504, longitude: -97.73353), color: .orange, title: "Darrell K Royal–Texas Memorial Stadium"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28561, longitude: -97.72937), color: .red, title: "LBJ Library"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28083, longitude: -97.73768), color: .blue, title: "Blanton Museum of Art"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28749, longitude: -97.73708), color: .blue, title: "Monochrome For Austin"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28702, longitude: -97.73230), color: .blue, title: "Texas Memorial Museum"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28431, longitude: -97.74092), color: .blue, title: "Harry Ransom Center"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28665, longitude: -97.74116), color: .cyan, title: "The UT Student Union"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28423, longitude: -97.73679), color: .cyan, title: "Gregory Gymnasium"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28465, longitude: -97.73973), color: .orange, title: "South Mall"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28302, longitude: -97.73708), color: .orange, title: "Jester Center"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28375, longitude: -97.73962), color: .blue, title: "The Littlefield Fountain"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28304, longitude: -97.73805), color: .red, title: "Perry-Castañeda Library"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28573, longitude: -97.73131), color: .cyan, title: "Bass Concert Hall"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28832, longitude: -97.73080), color: .orange, title: "UT Law School Building"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28359, longitude: -97.73964), color: .blue, title: "The Tower Garden"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.27482, longitude: -97.73631), color: .cyan, title: "UT's Outdoor Amphitheater"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28971, longitude: -97.73606), color: .blue, title: "Clock Knot"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28657, longitude: -97.73761), color: .blue, title: "Seven Mountains"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28685, longitude: -97.73769), color: .blue, title: "Welch Patio"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284792, longitude: -97.736327), color: .blue, title: "The Color Inside"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.289108, longitude: -97.740819), color: .blue, title: "And That's The Way It Is"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.27586, longitude: -97.73336), color: .blue, title: "Spiral of the Galaxy"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.283087, longitude: -97.73797), color: .blue, title: "Square Tilt"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.287883, longitude: -97.735634), color: .blue, title: "C-010106"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285636, longitude: -97.738276), color: .blue, title: "The West"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.286235, longitude: -97.737111), color: .blue, title: "Circle With Towers"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.287975, longitude: -97.740116), color: .blue, title: "Forever Free"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28587, longitude: -97.73572), color: .orange, title: "Jackson School of Geosciences"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28668, longitude: -97.73639), color: .green, title: "O's Campus Cafe and Catering"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28603, longitude: -97.74116), color: .green, title: "Union Coffee House")
]
