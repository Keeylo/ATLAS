//
//  ThirdRoundTowerViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/16/24.
//

import UIKit

class ThirdRoundTowerViewController: UIViewController {

    @IBOutlet weak var towerButton: UIButton!
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        towerButton.frame = CGRect(x: 204, y: 55, width: 25, height: 45)
        
        var configuration = UIButton.Configuration.filled()

        configuration.image = UIImage(named: "Image 4")
        configuration.imagePadding = 8
        configuration.imagePlacement = .leading
        towerButton.configuration = configuration
        
        let rotationAngle = CGFloat(25) * CGFloat.pi / 180
        towerButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
        towerButton.backgroundColor = .clear
        towerButton.tintColor = .clear
    }
    
    @IBAction func towerButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
        let winnerVC = storyboard.instantiateViewController(withIdentifier: "WonGame") as? WonGameViewController
        
        let otherVC = delegate as! ScreenChanger
        otherVC.changeScreen(vc: winnerVC!)
        
        let otherVC2 = delegate as! TimerStops
        otherVC2.stopsTimer()
        
        let otherVC3 = delegate as! GameWon
        otherVC3.didWinGame()
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
