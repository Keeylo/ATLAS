//
//  LocationInfoViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 11/12/24.
//

import Foundation
import UIKit
import GEOSwift
import FirebaseAuth
import FirebaseFirestore



class LocationInfoViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionBodyLabel: UILabel!
    @IBOutlet weak var tagsStackView: UIStackView!

    var images: [UIImage] = []
    var currentImageIndex = 0
    var coordinates: Coordinate?
    var locationTitle: String = "Unknown"
//    var locationName: String?
    
    var delegate: UIViewController!
    
    
    
    let locationData: [String: (description: String, tags: [String], images: [String])] = [
            "UT Tower, Main Building": (
                description: "The UT Tower is a symbol of the University of Texas, known for its stunning architecture and panoramic views.",
                tags: ["Study Rooms", "Event Spaces"],
                images: ["ut_tower_image", "ut_tower_image2"]
            ),
            "Circle With Towers": (
                description: "This minimalist sculpture features eight rectangular towers in a rhythmic circular formation, emphasizing geometry and simplicity.",
                tags: ["Minimalism", "Geometry", "Art"],
                images: ["circle_with_towers_image1", "circle_with_towers_image2"]
            ),
            "The West": (
                description: "Two large buoys covered in corroded pennies explore themes of capitalism, exploration, and industrial history.",
                tags: ["Sculpture", "Conceptual Art"],
                images: ["the_west_image1", "the_west_image2", "the_west_image3"]
            ),
            "Monochrome For Austin": (
                description: "This sculpture features 70 canoes balanced precariously, symbolizing motion, rhythm, and solitude.",
                tags: ["Large-Scale Art", "Sculpture"],
                images: ["monochrome_for_austin_image1", "monochrome_for_austin_image2"]
            ),
            "Gregory Gymnasium": ( 
                description: "Gregory Gymnasium is the main fitness and recreation center at UT Austin, offering a variety of sports facilities including swimming pools, basketball courts, and fitness studios.",
                tags: ["Fitness Center", "Sports"],
                images: ["gregory_gym_image1", "gregGood"]
            ),
            "Norman Hackerman Building": ( 
                description: "The Norman Hackerman Building is a state-of-the-art facility dedicated to chemistry and biology research, featuring advanced laboratories and modern lecture halls.",
                tags: ["Science", "Research", "Education"],
                images: ["norman_hackerman_image1", "normanGood"]
            ),
            "The Littlefield Fountain": (
                description: "The Littlefield Fountain is a World War I memorial adorned with bronze sculptures and cascading water, serving as a historic landmark on campus.",
                tags: ["Memorial", "Sculpture", "History"],
                images: ["littlefield_fountain_image1", "fountainGooder"]
            ),
            "The UT Student Union": (
                description: "The Texas Union is a central hub for student life, offering dining options, study spaces, and venues for various events and activities.",
                tags: ["Student Center", "Dining", "Events"],
                images: ["texas_union_image1", "unionGood"]
            ),
            "EER": (
                description: "The Engineering Education and Research Center (EER) is a cutting-edge facility that fosters innovation and collaboration among engineering students and faculty.",
                tags: ["Engineering", "Innovation", "Education"],
                images: ["eer_building_image1", "eerGood"]
            ),
            "Blanton Museum of Art": (
                description: "The Blanton Museum of Art houses an extensive collection of art from various periods and cultures, featuring modern and contemporary works and rotating exhibitions.",
                tags: ["Art Museum", "Exhibitions", "Culture"],
                images: ["blanton_museum_image1", "blantonGood"]
            ),
            "Clock Knot": (
                description: "Clock Knot is a large-scale outdoor sculpture by artist Mark di Suvero, featuring interlocking red steel beams that explore themes of time and complexity.",
                tags: ["Sculpture", "Public Art", "Modern Art"],
                images: ["clock_knot_image1", "clockknotGood"]
            ),
            "Darrell K Royal–Texas Memorial Stadium": (
                description: "Home to the Texas Longhorns football team, this iconic stadium is known for its roaring crowds and state-of-the-art facilities.",
                tags: ["Sports", "Football", "Landmark"],
                images: ["darrell_k_royal_stadium_image1", "darrell_k_royal_stadium_image2"]
            ),
            "LBJ Library": (
                description: "The Lyndon B. Johnson Library and Museum offers a glimpse into the life and legacy of the 36th U.S. president, with exhibits and archives detailing American history.",
                tags: ["Presidential Library", "History", "Education"],
                images: ["lbj_library_image1", "lbj_library_image2"]
            ),
            "Texas Memorial Museum": (
                description: "Dedicated to natural history, this museum features exhibits on fossils, wildlife, and geological wonders of Texas.",
                tags: ["Natural History", "Education", "Museum"],
                images: ["texas_memorial_museum_image1", "texas_memorial_museum_image2"]
            ),
            "Harry Ransom Center": (
                description: "A world-class research library and museum, the Harry Ransom Center houses rare books, manuscripts, and art collections.",
                tags: ["Research", "Art", "Library"],
                images: ["harry_ransom_center_image1", "harry_ransom_center_image2"]
            ),
            "South Mall": (
                description: "A picturesque area of the UT campus featuring lush greenery, historic statues, and a stunning view of the UT Tower.",
                tags: ["Landmark", "History", "Scenic"],
                images: ["south_mall_image1", "south_mall_image2"]
            ),
            "Jester Center": (
                description: "Jester Center is a vibrant hub for student life, offering housing, dining, and communal spaces for UT students.",
                tags: ["Student Housing", "Dining", "Community"],
                images: ["jester_center_image1", "jester_center_image2"]
            ),
            "Perry-Castañeda Library": (
                description: "The PCL is UT's largest library, offering extensive study spaces, academic resources, and digital archives.",
                tags: ["Library", "Study Spaces", "Education"],
                images: ["pcl_library_image1", "pcl_library_image2"]
            ),
            "Bass Concert Hall": (
                description: "This premier performing arts venue hosts a wide range of events, from Broadway productions to live music and lectures.",
                tags: ["Performing Arts", "Concerts", "Theater"],
                images: ["bass_concert_hall_image1", "bass_concert_hall_image2"]
            ),
            "UT Law School Building": (
                description: "The UT Law School Building features state-of-the-art classrooms, lecture halls, and study spaces for aspiring lawyers.",
                tags: ["Education", "Law", "Research"],
                images: ["ut_law_school_image1", "ut_law_school_image2"]
            ),
            "The Tower Garden": (
                description: "Located near the UT Tower, this serene garden provides a peaceful environment for relaxation and reflection.",
                tags: ["Garden", "Relaxation", "Landmark"],
                images: ["tower_garden_image1", "tower_garden_image2"]
            ),
            "UT's Outdoor Amphitheater": (
                description: "This open-air venue is perfect for performances, events, and casual gatherings under the Texas sky.",
                tags: ["Outdoor", "Events", "Performances"],
                images: ["ut_amphitheater_image1", "ut_amphitheater_image2"]
            ),
            "Seven Mountains": (
                description: "A unique outdoor art installation featuring seven towering, colorful stone pillars stacked to symbolize unity and balance.",
                tags: ["Art Installation", "Sculpture", "Outdoor"],
                images: ["seven_mountains_image1", "seven_mountains_image2"]
            ),
            "Welch Patio": (
                description: "An outdoor area near Welch Hall, providing a quiet space for students and faculty to study or relax.",
                tags: ["Outdoor", "Study Spaces", "Relaxation"],
                images: ["welch_patio_image1", "welch_patio_image2"]
            ),
            "The Color Inside": (
                description: "A Skyspace installation by artist James Turrell, creating a mesmerizing play of light and color at sunset and sunrise.",
                tags: ["Skyspace", "Light Art", "Installation"],
                images: ["the_color_inside_image1", "the_color_inside_image2"]
            ),
            "And That's The Way It Is": (
                description: "A striking wall sculpture paying homage to Walter Cronkite, featuring iconic quotes and themes from his journalism career.",
                tags: ["Journalism", "Art", "Tribute"],
                images: ["and_thats_the_way_it_is_image1", "and_thats_the_way_it_is_image2"]
            ),
            "Spiral of the Galaxy": (
                description: "This large, spiraling outdoor sculpture symbolizes the vastness and complexity of the universe.",
                tags: ["Sculpture", "Public Art", "Abstract"],
                images: ["spiral_of_the_galaxy_image1", "spiral_of_the_galaxy_image2"]
            ),
            "Square Tilt": (
                description: "A modern geometric sculpture exploring themes of balance and perspective through its tilted square design.",
                tags: ["Sculpture", "Modern Art", "Geometry"],
                images: ["square_tilt_image1", "square_tilt_image2"]
            ),
            "C-010106": (
                description: "A contemporary art installation known for its abstract design and thought-provoking themes.",
                tags: ["Art Installation", "Abstract", "Contemporary"],
                images: ["c_010106_image1", "c_010106_image2"]
            ),
            "Forever Free": (
                description: "A memorial sculpture celebrating the enduring spirit of freedom and justice.",
                tags: ["Memorial", "Sculpture", "Tribute"],
                images: ["forever_free_image1", "forever_free_image2"]
            ),
            "Jackson School of Geosciences": (
                description: "A leading institution for geological research and education, with facilities for advanced scientific exploration.",
                tags: ["Geosciences", "Education", "Research"],
                images: ["jackson_school_image1", "jackson_school_image2"]
            ),
            "O's Campus Cafe and Catering": (
                description: "A popular campus dining spot known for its fresh, locally sourced meals and catering services.",
                tags: ["Dining", "Cafe", "Catering"],
                images: ["os_campus_cafe_image1", "os_campus_cafe_image2"]
            ),
            "Union Coffee House": (
                description: "Located in the Texas Union, this cozy coffee house serves a variety of beverages and snacks, perfect for studying or socializing.",
                tags: ["Coffee", "Student Center", "Relaxation"],
                images: ["union_coffee_house_image1", "union_coffee_house_image2"]
            )
    ]


    override func viewDidLoad() {
            super.viewDidLoad()
            
    //        if let locationTitle = locationTitle {
    //            if let data = locationData[locationTitle] {
    //                setupLocationInfo(name: locationTitle, description: data.description, tags: data.tags, images: data.images)
    //            } else {
    //                print("Error: No location data found for this location name.")
    //            }
    //        } else {
    //            print("Error: Location name not provided.")
    //        }
            
            print("mono title: \(locationTitle)")
            
            if let data = locationData[locationTitle] {
                setupLocationInfo(name: locationTitle, description: data.description, tags: data.tags, images: data.images)
            } else {
                print("Error: No location data found for this location name.")
            }
            
//            unlockLocation()
        }

        func setupLocationInfo(name: String, description: String, tags: [String], images: [String]) {
                titleLabel.text = name
                descriptionLabel.text = "Description:"
                descriptionBodyLabel.text = description
                
                // Ensure the labels resize to fit their content
                titleLabel.sizeToFit()
                descriptionBodyLabel.sizeToFit()
            
                // Load images
                self.images = images.compactMap { UIImage(named: $0) }
                updateImageView()
                
                // Setup tags
                setupTags(tags)
            }

        func setupTags(_ tags: [String]) {
            // Clear any existing tags from the stack view
            tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for tag in tags {
                let tagButton = UIButton(type: .system)
                
                // Use a filled configuration with padding and corner style
                var config = UIButton.Configuration.filled()
                config.title = tag
                config.baseBackgroundColor = .systemOrange
                config.baseForegroundColor = .white
                config.cornerStyle = .capsule // Gives a rounded, capsule-style button
                config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)

                tagButton.configuration = config

                // Optionally, add an action if you want the button to be interactive
                tagButton.addTarget(self, action: #selector(tagButtonTapped(_:)), for: .touchUpInside)

                // Add the button to the stack view
                tagsStackView.addArrangedSubview(tagButton)
                
                tagButton.translatesAutoresizingMaskIntoConstraints = false
                tagButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
        }
        
        @objc func tagButtonTapped(_ sender: UIButton) {
            if let tagTitle = sender.title(for: .normal) {
                print("Tag \(tagTitle) tapped")
            }
        }

        func updateImageView() {
            if !images.isEmpty {
                imageView.image = images[currentImageIndex]
                imageView.contentMode = .scaleAspectFit // Ensure the image scales properly
            }
        }

        @IBAction func nextImage(_ sender: UIButton) {
            currentImageIndex = (currentImageIndex + 1) % images.count
            updateImageView()
        }

        @IBAction func previousImage(_ sender: UIButton) {
            currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
            updateImageView()
        }
        
        func unlockLocation() {
            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                let userRef = db.collection("users").document(user.uid)
                
                // Update the username field (or any other field you want)
                userRef.updateData([
                    "locations": FieldValue.arrayUnion([self.locationTitle])
                ]) { error in
                    if let error = error {
                        print("Error updating user data: \(error.localizedDescription)")
                    } else {
                        if (self.locationTitle != "Unknown") {
                            let otherVC = self.delegate as! LocationUnlocker
                            
                            otherVC.unlockLocation(locationName: self.locationTitle)
                            print("Location successfully unlocked!")
                        }
                    }
                }
            } else {
                print("couldn't authenticate user")
            }
        }

    //    // CLLocationManagerDelegate method
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        guard let userLocation = locations.last else { return }
    //
    //        let userPoint = Point(x: userLocation.coordinate.latitude, y: userLocation.coordinate.longitude)
    //
    ////        // Check proximity to all predefined locations
    ////        checkProximity(to: userPoint)
    //    }

    //    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    //        print("Failed to get user location: \(error.localizedDescription)")
    //    }
    //
    //    func checkProximity(to userPoint: Point) {
    //        // Iterate over all locations to find the closest match within 50 meters
    //        for location in locationsData {
    //            let distanceInMeters = try? userPoint.distance(to: location.coordinate)
    //            if let distance = distanceInMeters, distance <= 50 {
    //                print("User is within 50 meters of \(location.name).")
    //                setupData(for: location)
    //                return
    //            }
    //        }
    //
    //        // If no location is nearby, show an alert
    //        print("User is not within 50 meters of any known location.")
    //        let alert = UIAlertController(title: "Location Not Found", message: "You are not near any of the predefined locations.", preferredStyle: .alert)
    //        alert.addAction(UIAlertAction(title: "OK", style: .default))
    //        present(alert, animated: true)
    //    }
    }

    //struct Coordinate: Hashable {
    //    let latitude: Double
    //    let longitude: Double
    //
    //    init(_ coordinate: CLLocationCoordinate2D) {
    //        self.latitude = coordinate.latitude
    //        self.longitude = coordinate.longitude
    //    }
    //
    //    init(latitude: Double, longitude: Double) {
    //        self.latitude = latitude
    //        self.longitude = longitude
    //    }
    //
    //    var clCoordinate: CLLocationCoordinate2D {
    //        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    //    }
    //
    //    func hash(into hasher: inout Hasher) {
    //        hasher.combine(latitude)
    //        hasher.combine(longitude)
    //    }
    //
    //    static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
    //        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    //    }
    //
    //}
