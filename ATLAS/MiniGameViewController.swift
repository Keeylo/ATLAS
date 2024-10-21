//
//  MiniGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/15/24.
//

import UIKit
import FirebaseAuth


// protocol that changes this VC's textLabel.text
protocol ScreenChanger {
    func changeScreen(vc: UIViewController)
}

protocol TimerStops {
    func stopsTimer()
}

class MiniGameViewController: UIViewController, ScreenChanger, TimerStops {
    
    @IBOutlet weak var controllerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pausePlayButton: UIButton!

    @IBOutlet weak var givenHints: UILabel!
    @IBOutlet weak var hintsButton: UIButton!
    @IBOutlet weak var outOfHintsLabel: UILabel!
    @IBOutlet weak var anotherHintButton: UIButton!
    
    @IBOutlet weak var quitButton: UIButton!
    
    var currentChildViewController: UIViewController?
    var instructionsVC: UIViewController?
    var miniGameChildVC: UIViewController?
    
//    var hints1: String = "hint 1" // need to prep b4 segue
//    var hints2: String = "hint 2" // need to prep b4 segue
//    var hints3: String = "hint 3" // need to prep b4 segue
    var hints:[String] = ["hint 1", "hint 2", "hint 3"] // need to prep b4 segue
    var totalHints = 3 // need to be prep b4 segue (might have less than 3, but max 3)
    var hintCount = 3
    var hintsIndex = 0
    
    var timer: Timer?
    var timeLeft: Int = 60 // possibly need to prep b4 segue
    var timerPaused: Bool = true
    
    var gameLocation: String = "Tower" // need to prep b4 segue
    var gameStarted = false
    
    var gameInstructions = "You will have 60 seconds to complete 3 rounds of finding the hidden UT Tower amongst similar objects. Press the play button to begin!" // need to prep b4 segue
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        timerLabel.text = ""
        
        givenHints.text = ""
//        givenHints.sizeToFit()
        outOfHintsLabel.isHidden = true
        anotherHintButton.isHidden = true
        hintCount = totalHints
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructionsVC = storyboard.instantiateViewController(withIdentifier: "GameInstructions") as? GameInstructionsViewController
        
        instructionsVC?.instructions = gameInstructions
        
        displayChildViewController(instructionsVC!)
        
    }
    
    func displayChildViewController(_ child: UIViewController) {
        // Remove the current child view controller if any
        if let currentChild = currentChildViewController {
            currentChild.willMove(toParent: nil)
            currentChild.view.removeFromSuperview()
            currentChild.removeFromParent()
        }

        // Add the new child view controller
        addChild(child)
        child.view.frame = controllerView.bounds
        controllerView.addSubview(child.view)
        child.didMove(toParent: self)

        // Update the current child reference
        currentChildViewController = child
    }
    
    @IBAction func hintsButtonPressed(_ sender: Any) {
        if (hintCount == totalHints && gameStarted) {
            revealHints()
        }
    }
    
    func revealHints() {
        if (hintCount > 0) {
            if (hintsIndex == 0) {
                anotherHintButton.isHidden = false
            }
            givenHints.text = hints[hintsIndex]
            hintsIndex += 1
            hintCount -= 1
        } else {
            outOfHintsLabel.isHidden = false
        }
    }
    
    // reveals next hint, or if there are no more hints, it tells the user they are out of hints
    @IBAction func anotherHintButtonPressed(_ sender: Any) {
        revealHints()
    }
    
    // if the quit button is pressed, then user is taken back to the map screen
    @IBAction func quitButtonPressed(_ sender: Any) {
        
    }
    
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        pauseResumeGame()
    }
    
    func pauseResumeGame() {
        if (gameStarted == false) {
            gameStarted = true
            if (gameLocation == "Tower") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let round1VC = storyboard.instantiateViewController(withIdentifier: "FirstRoundTower") as? FirstRoundTowerViewController
                round1VC?.delegate = self
                displayChildViewController(round1VC!)
            }
        }
        timerPaused.toggle()
        if let currentImage = pausePlayButton.image(for: .normal) {
            if currentImage.isEqual(UIImage(systemName: "pause.fill")) {
                pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                pauseTimer()
                showPausedAlert()
            } else if currentImage.isEqual(UIImage(systemName: "play.fill")) {
                startCountdown()
                pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
    }
    
    func showPausedAlert() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        
        let controller = UIAlertController(title: "Resume Game", message: "Press 'Resume' to keep playing.    Press 'Restart' to restart the game.", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (action: UIAlertAction!) in
            blurVisualEffectView.removeFromSuperview()
            self.resetMiniGame()
        }))
        controller.addAction(UIAlertAction(title: "Resume", style: .default, handler: { (action: UIAlertAction!) in
            blurVisualEffectView.removeFromSuperview()
            self.pauseResumeGame()
        }))
        
        view.addSubview(blurVisualEffectView)
        
        present(controller, animated: true)
    }
    
    func startCountdown() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc func updateCountdown() {
        if timeLeft > 0 {
            timeLeft -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            timer = nil
            
            timerLabel.text = "Time's up!"
            
            let className = String(describing: type(of: currentChildViewController))
            if (className != "WonGameViewController") {
                let controller = UIAlertController(title: "You ran out of time!", message: "Do you want to try again?", preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "No", style: .default))
                controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.resetMiniGame()
                }))
                present(controller, animated: true)
            }
        }
    }

    func updateTimerLabel() {
        timerLabel.text = "Timer: \(timeLeft)s"
    }
    
    func pauseTimer() {
        timer?.invalidate() // Stop the timer
        //timer = nil // Clear the timer reference
    }
    
    func resetMiniGame() {
        
        pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        pauseTimer()
        timeLeft = 60
        timerLabel.text = ""
        
        gameStarted = false
        
//        givenHints.text = ""
//        givenHints.sizeToFit()
//        givenHints.text = """
//            hint 1
//            hint 2
//            hint 3
//        """
        givenHints.text = ""
        outOfHintsLabel.isHidden = true
        anotherHintButton.isHidden = true
        hintCount = totalHints
        hintsIndex = 0
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instructionsVC = storyboard.instantiateViewController(withIdentifier: "GameInstructions") as? GameInstructionsViewController
        
        instructionsVC?.instructions = gameInstructions
        
        displayChildViewController(instructionsVC!)
    }
    
    func changeScreen(vc: UIViewController) {
        displayChildViewController(vc)
    }
    
    func stopsTimer() {
        pauseTimer()
    }
    

}



// code for sign out alert
//
//let controller = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
//
//controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: signOut(alert:)))
//
//present(controller, animated: true)
//
//
//func signOut(alert: UIAlertAction) {
//    do {
//        try Auth.auth().signOut()
//        // segue to login screen
//    } catch {
//        let controller = UIAlertController(title: "Error", message: "Account deletion failed. Try again.", preferredStyle: .alert)
//
//        controller.addAction(UIAlertAction(title: "Okay", style: .cancel))
//    }
//
//    performSegue(withIdentifier: "SignOutSegure", sender: self) // add segue in storyboard
//}
//
//override func prepare(for segue:UIStoryboardSegue, sender:Any?) {
//    
//    if segue.identifier == "SignOutSegue", let nextVC = segue.destination as? LoginViewController {
//        // add prep code
//    }
//}




// code for delete account alert

//let controller = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? All progress will be lost.", preferredStyle: .alert)
//
//controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: deleteAccount(alert:)))
//
//present(controller, animated: true)
//
//
//func deleteAccount(alert: UIAlertAction) {
//    let user = Auth.auth().currentUser
//    
//    user?.delete()
//    
//    performSegue(withIdentifier: "DeleteAccountSegure", sender: self) // add segue in storyboard
//}
//
//override func prepare(for segue:UIStoryboardSegue, sender:Any?) {
//    
//    if segue.identifier == "DeleteAccountSegue", let nextVC = segue.destination as? LoginViewController {
//        // add prep code
//    }
//}






