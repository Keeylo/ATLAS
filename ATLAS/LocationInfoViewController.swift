//
//  LocationInfoViewController.swift
//  ATLAS
//
//  Created by Pranitha  Kolli  on 11/10/24.
//

import Foundation
import UIKit
import CoreLocation
import GEOSwift

class LocationInfoViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionBodyLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tagsStackView: UIStackView!

    var locationManager = CLLocationManager()
    let targetLocation = Point(x: 30.2862, y: -97.7394) // UT Tower coordinates
    var images: [UIImage] = []
    var currentImageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupDummyData()
        updateImageView()
    }

    func setupDummyData() {
        titleLabel.text = "UT Tower"
        images = [UIImage(named: "ut_tower_image")!, UIImage(named: "ut_tower_image2")!]
        descriptionLabel.text = "Description:"
        descriptionBodyLabel.text = "The UT Tower, a prominent symbol of the University of Texas at Austin, stands at 307 feet and is renowned for its stunning architecture and panoramic views."
        let tags = ["Study Rooms", "Event Spaces"]
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
        imageView.image = images[currentImageIndex]
    }

    @IBAction func nextImage(_ sender: UIButton) {
        currentImageIndex = (currentImageIndex + 1) % images.count
        updateImageView()
    }

    @IBAction func previousImage(_ sender: UIButton) {
        currentImageIndex = (currentImageIndex - 1 + images.count) % images.count
        updateImageView()
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        
        let userPoint = Point(x: userLocation.coordinate.latitude, y: userLocation.coordinate.longitude)
        
        checkProximity(to: userPoint)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    func checkProximity(to userPoint: Point) {
        let distanceInMeters = try? userPoint.distance(to: targetLocation)

        if let distance = distanceInMeters, distance <= 50 {
            print("User is within 50 meters of the UT Tower.")
            // Optionally show an alert or update UI
        } else {
            print("User is not within 50 meters of the UT Tower.")
            let alert = UIAlertController(title: "Not at UT Tower", message: "You are not at the UT Tower location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

}
