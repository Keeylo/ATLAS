//
//  MenuPopUpViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/22/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MenuPopUpViewController: UIViewController {
    
    @IBOutlet weak var unlockedButton: UIButton!
    @IBOutlet weak var userGuideButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func unlockedPressed(_ sender: Any) {
    }
    
    
    @IBAction func userGuidePressed(_ sender: Any) {
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.origin.y = self.view.frame.height + 700
        }) { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }

    
}
