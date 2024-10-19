//
//  GameInstructionsViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/16/24.
//

import UIKit

class GameInstructionsViewController: UIViewController {

    @IBOutlet weak var instructionsView: UIView!
    
    @IBOutlet weak var miniView: UIView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var instructions: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionsView.layer.masksToBounds = true
        instructionsView.layer.cornerRadius = 20
        
        instructionsLabel.layer.masksToBounds = true
        instructionsLabel.layer.cornerRadius = 10

        instructionsLabel.text = instructions
    }
    

}
