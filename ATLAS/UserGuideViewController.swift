//
//  UserGuideViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/21/24.
//

import UIKit

class UserGuideViewController: UIViewController {
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var markerTypesButton: UIButton!
    @IBOutlet weak var mapDiscoveryButton: UIButton!
    @IBOutlet weak var miniGamesButton: UIButton!
    @IBOutlet weak var userSettingsButton: UIButton!
    @IBOutlet weak var extraButton: UIButton!
    
    private var selectedButton: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markerTypesButton.setTitleColor(.systemBlue, for: .normal)
        mapDiscoveryButton.setTitleColor(.systemBlue, for: .normal)
        miniGamesButton.setTitleColor(.systemBlue, for: .normal)
        userSettingsButton.setTitleColor(.systemBlue, for: .normal)
        extraButton.setTitleColor(.systemBlue, for: .normal)
        
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
        
        selectedButton = markerTypesButton
        highlightButton(markerTypesButton)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        print("Button tapped")
        highlightButton(sender)
    }
    
    private func highlightButton(_ button: UIButton) {
        print("Highlighting button")
        selectedButton?.setTitleColor(.systemBlue, for: .normal)
        
        button.setTitleColor(.systemRed, for: .normal) // highlighted text color

        selectedButton = button
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
