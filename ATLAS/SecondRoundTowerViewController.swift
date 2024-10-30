//
//  SecondRoundTowerViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/16/24.
//

import UIKit

class SecondRoundTowerViewController: UIViewController {

    @IBOutlet weak var towerButton: UIButton!
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        towerButton.frame = CGRect(x: 230, y: 360, width: 30, height: 84)
        
        var configuration = UIButton.Configuration.filled()

        configuration.image = UIImage(named: "Image 3")
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        towerButton.configuration = configuration
        
//        let rotationAngle = CGFloat(-30) * CGFloat.pi / 180
//        towerButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
        towerButton.backgroundColor = .clear
        towerButton.tintColor = .clear
    }
    

    @IBAction func towerButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
        let round3VC = storyboard.instantiateViewController(withIdentifier: "ThirdRoundTower") as? ThirdRoundTowerViewController
        
        round3VC?.delegate = delegate
        
        let otherVC = delegate as! ScreenChanger
        otherVC.changeScreen(vc: round3VC!)
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
