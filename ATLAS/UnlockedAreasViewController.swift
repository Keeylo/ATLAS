//
//  UnlockedAreasViewController.swift
//  ATLAS
//
//  Created by Eric Rodriguez on 10/21/24.
//

import UIKit

class UnlockedAreasViewController: UIViewController {

    @IBOutlet weak var sunnySideUp: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rotationAngle = CGFloat(-15) * CGFloat(Double.pi) / 180  // 45 degrees in radians
        sunnySideUp.transform = CGAffineTransform(rotationAngle: rotationAngle)
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
