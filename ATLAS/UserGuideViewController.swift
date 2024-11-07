//
//  UserGuideViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/21/24.
//

import UIKit

class UserGuideViewController: UIViewController {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var markerTypesButton: UIButton!
    @IBOutlet weak var mapDiscoveryButton: UIButton!
    @IBOutlet weak var miniGamesButton: UIButton!
    @IBOutlet weak var userSettingsButton: UIButton!
    @IBOutlet weak var extraButton: UIButton!
    
    private var selectedButton: UIButton?
    private var images: [UIImage] = []
    
    enum Section: Int {
        case markerTypes = 0
        case mapDiscovery
        case miniGames
        case userSettings
        case extra
    }

    private let sectionData: [Section: (images: [UIImage], description: String)] = [
        .markerTypes: (
            images: [UIImage(named: "image 14")!, UIImage(named: "Image 10")!],
            description: "Description for Marker Types"
        ),
        .mapDiscovery: (
            images: [UIImage(named: "Image 10")!, UIImage(named: "image 14")!],
            description: "Description for Map Discovery"
        ),
        .miniGames: (
            images: [UIImage(named: "image 14")!],
            description: "Description for Mini Games"
        ),
        .userSettings: (
            images: [UIImage(named: "Image 10")!],
            description: "Description for User Settings"
        ),
        .extra: (
            images: [UIImage(named: "image 14")!, UIImage(named: "Image 10")!],
            description: "Description for Extra"
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.sizeToFit()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        mainImageView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        mainImageView.addGestureRecognizer(swipeRight)
        
        mainImageView.isUserInteractionEnabled = true
        
        let buttons = stackView.arrangedSubviews.compactMap { $0 as? UIButton }
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, button) in buttons.enumerated() {
            // Center align the button text
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.numberOfLines = 0  // Allow multiple lines
            button.titleLabel?.lineBreakMode = .byWordWrapping
            
            // Add button back to stack view
            stackView.addArrangedSubview(button)
            
            // Add separator after each button except the last one
            if index < buttons.count - 1 {
                let separator = UIView()
                separator.backgroundColor = .black
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(separator)
            }
        }
        
        markerTypesButton.tag = Section.markerTypes.rawValue
        mapDiscoveryButton.tag = Section.mapDiscovery.rawValue
        miniGamesButton.tag = Section.miniGames.rawValue
        userSettingsButton.tag = Section.userSettings.rawValue
        extraButton.tag = Section.extra.rawValue
        
        selectedButton = markerTypesButton
        highlightButton(markerTypesButton)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        print("Button tapped")
        highlightButton(sender)
    }
    
    @IBAction func pageControlChanged(_ sender: UIPageControl) {
        mainImageView.image = images[sender.currentPage]
    }
    
    private func updateContent(for section: Section) {
        if let data = sectionData[section] {
            self.images = data.images
            self.descriptionLabel.text = data.description
            
            self.pageControl.numberOfPages = self.images.count
            self.pageControl.currentPage = 0
            self.mainImageView.image = self.images.first
        }
    }

    
    private func highlightButton(_ button: UIButton) {
        print("Highlighting button")
        selectedButton?.backgroundColor = .clear
                
        // Highlight new button
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        // Update selected button
        selectedButton = button
        sectionTitleLabel.text = button.titleLabel?.text
        
        if let section = Section(rawValue: button.tag) {
            updateContent(for: section)
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if pageControl.currentPage < images.count - 1 {
                pageControl.currentPage += 1
            }
        } else if gesture.direction == .right {
            if pageControl.currentPage > 0 {
                pageControl.currentPage -= 1
            }
        }
        mainImageView.image = images[pageControl.currentPage]
    }
    
    /*
    // MARK: - TODO
    // Get everything connected, select whether back to map uses segway or popViewController or IBAction
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
