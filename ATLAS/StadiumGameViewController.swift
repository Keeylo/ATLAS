//
//  StadiumGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 12/5/24.
//

import UIKit

class StadiumGameViewController: UIViewController {
    
    @IBOutlet weak var cupImage: UIImageView!
    @IBOutlet weak var bottleImage: UIImageView!
    @IBOutlet weak var tomatoImage: UIImageView!
    @IBOutlet weak var canImage: UIImageView!
    @IBOutlet weak var bananaImage: UIImageView!
    @IBOutlet weak var paperBallImage: UIImageView!
    @IBOutlet weak var appleImage: UIImageView!
    @IBOutlet weak var trashCanImage: UIImageView!
    
    var trashItemsLeft = 7
    
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // if a trash item is dragged to the trash can, then the item is hidden.
    // if the user has dragged all of the items to trashcan, then they win
    // the game
    @IBAction func handleDragGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        
        recognizer.setTranslation(.zero, in: self.view)
        
        if (recognizer.state == .ended) {
            if (recognizer.view!.frame).intersects(trashCanImage.frame) {
                recognizer.view!.isHidden = true
                trashItemsLeft -= 1
                
                if (trashItemsLeft == 0) {
                    let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
                    let winnerVC = storyboard.instantiateViewController(withIdentifier: "WonGame") as? WonGameViewController
                    
                    let otherVC = delegate as! ScreenChanger
                    otherVC.changeScreen(vc: winnerVC!)
                    
                    let otherVC2 = delegate as! TimerStops
                    otherVC2.stopsTimer()
                    
                    let otherVC3 = delegate as! GameWon
                    otherVC3.didWinGame()
                }
            }
        }
    }

}
