import UIKit
import CoreLocation

struct PointOfInterest {
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    let title: String
}

let pointsOfInterest: [PointOfInterest] = [
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.2862, longitude: -97.7394), color: .orange, title: "UT Tower"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284713, longitude: -97.734732), color: .orange, title: "Darrell K Royal–Texas Memorial Stadium"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285823, longitude: -97.731578), color: .red, title: "LBJ Library"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284407, longitude: -97.737020), color: .blue, title: "Blanton Museum of Art"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284507, longitude: -97.738316), color: .red, title: "The Main Building"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.287462, longitude: -97.737132), color: .blue, title: "Monochrome For Austin"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284672, longitude: -97.731078), color: .blue, title: "Texas Memorial Museum"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284523, longitude: -97.741015), color: .blue, title: "Harry Ransom Center"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.283456, longitude: -97.740166), color: .cyan, title: "The UT Student Union"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285227, longitude: -97.736045), color: .cyan, title: "Gregory Gymnasium"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284734, longitude: -97.738758), color: .orange, title: "The UT Tower Plaza"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285998, longitude: -97.737715), color: .orange, title: "Jester Center"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285669, longitude: -97.738211), color: .blue, title: "The Littlefield Fountain"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.270809, longitude: -97.737698), color: .orange, title: "The Dell Medical School"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.2827, longitude: -97.7382), color: .red, title: "Perry-Castañeda Library"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285993, longitude: -97.735417), color: .cyan, title: "Texas Performing Arts Complex"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.283087, longitude: -97.736952), color: .orange, title: "UT Law School Building"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284582, longitude: -97.738150), color: .blue, title: "The Tower Garden"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284943, longitude: -97.735367), color: .cyan, title: "UT's Outdoor Amphitheater"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.289671, longitude: -97.736162), color: .blue, title: "Clock Knot"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.28640025, longitude: -97.73749122), color: .blue, title: "Seven Mountains"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.284792, longitude: -97.736327), color: .blue, title: "The Color Inside"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.289108, longitude: -97.740819), color: .blue, title: "And That's The Way It Is"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.27586, longitude: -97.73336), color: .blue, title: "Spiral of the Galaxy"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.283087, longitude: -97.73797), color: .blue, title: "Square Tilt"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.287883, longitude: -97.735634), color: .blue, title: "C-010106"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.285636, longitude: -97.738276), color: .blue, title: "The West"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.286235, longitude: -97.737111), color: .blue, title: "Circle With Towers"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.287975, longitude: -97.740116), color: .blue, title: "Forever Free"),
    PointOfInterest(coordinate: CLLocationCoordinate2D(latitude: 30.2858, longitude: -97.7358), color: .orange, title: "Jackson School of Geosciences")
]
