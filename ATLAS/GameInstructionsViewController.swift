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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionsView.layer.masksToBounds = true
        instructionsView.layer.cornerRadius = 20
        
        instructionsLabel.layer.masksToBounds = true
        instructionsLabel.layer.cornerRadius = 10
        instructionsLabel

        // Do any additional setup after loading the view.
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
