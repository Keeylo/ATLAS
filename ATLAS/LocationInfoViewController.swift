//
//  LocationInfoViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 11/12/24.
//

import Foundation
import UIKit
import GEOSwift

class LocationInfoViewController: UIViewController{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionBodyLabel: UILabel!
    @IBOutlet weak var tagsStackView: UIStackView!

    var images: [UIImage] = []
    var currentImageIndex = 0
    var coordinates: Coordinate?
    var locationTitle: String = "Unknown"
    var locationName: String?
    
    let locationData: [String: (description: String, tags: [String], images: [String])] = [
            "UT Tower": (
                description: "The UT Tower is a symbol of the University of Texas, known for its stunning architecture and panoramic views.",
                tags: ["Study Rooms", "Event Spaces"],
                images: ["ut_tower_image", "ut_tower_image2"]
            ),
            "Circle with Towers": (
                description: "This minimalist sculpture features eight rectangular towers in a rhythmic circular formation, emphasizing geometry and simplicity.",
                tags: ["Minimalism", "Geometry", "Art"],
                images: ["circle_with_towers_image1", "circle_with_towers_image2"]
            ),
            "The West": (
                description: "Two large buoys covered in corroded pennies explore themes of capitalism, exploration, and industrial history.",
                tags: ["Sculpture", "Conceptual Art"],
                images: ["the_west_image1", "the_west_image2", "the_west_image3"]
            ),
            "Monochrome for Austin": (
                description: "This sculpture features 70 canoes balanced precariously, symbolizing motion, rhythm, and solitude.",
                tags: ["Large-Scale Art", "Sculpture"],
                images: ["monochrome_for_austin_image1", "monochrome_for_austin_image2"]
            )
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let locationName = locationName {
            if let data = locationData[locationName] {
                setupLocationInfo(name: locationName, description: data.description, tags: data.tags, images: data.images)
            } else {
                print("Error: No location data found for this location name.")
            }
        } else {
            print("Error: Location name not provided.")
        }
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

