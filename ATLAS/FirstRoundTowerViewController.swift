//
//  FirstRoundTowerViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/16/24.
//

import UIKit

class FirstRoundTowerViewController: UIViewController {

    @IBOutlet weak var towerButton: UIButton!
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        towerButton.frame = CGRect(x: 267, y: 265, width: 39, height: 83)
        
        var configuration = UIButton.Configuration.filled()

        configuration.image = UIImage(named: "Image")
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        towerButton.configuration = configuration
        
        let rotationAngle = CGFloat(-30) * CGFloat.pi / 180
        towerButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
        towerButton.backgroundColor = .clear
        towerButton.tintColor = .clear
    }
    
    @IBAction func towerButtonPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let round2VC = storyboard.instantiateViewController(withIdentifier: "SecondRoundTower") as? SecondRoundTowerViewController
        round2VC?.delegate = delegate
        
        let otherVC = delegate as! ScreenChanger
        otherVC.changeScreen(vc: round2VC!)
    }
    

}
