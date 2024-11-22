//
//  MiniGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/15/24.
//

import UIKit
import FirebaseAuth
import CoreLocation



// protocol that changes this VC's textLabel.text
protocol ScreenChanger {
    func changeScreen(vc: UIViewController)
}

// protocol that pauses the timer
protocol TimerStops {
    func stopsTimer()
}

// protocol that changes the 'wonGame' variable
protocol GameWon {
    func didWinGame()
}

class MiniGameViewController: UIViewController, ScreenChanger, TimerStops, GameWon {
    
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
    var wonGame = false
    var locationTitle: String = "Unknown"
    var locationCoordinates: CLLocationCoordinate2D?

    
//    var hints1: String = "hint 1" // need to prep b4 segue
//    var hints2: String = "hint 2" // need to prep b4 segue
//    var hints3: String = "hint 3" // need to prep b4 segue
    var hints:[String] = ["Round 1: Look for the disco ball.", "Round 2: Look for the horse.", "Round 3: Look around the baby doll head."] // need to prep b4 segue
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
        
        let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
        let instructionsVC = storyboard.instantiateViewController(withIdentifier: "GameInstructions") as? GameInstructionsViewController
        
        instructionsVC?.instructions = gameInstructions
        
        displayChildViewController(instructionsVC!)
        
    }
    
    // changes the Container View to display the child VC 
    // passed in as parameter
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
    
    // reveals the next hint if the game has started,
    // or displays no more hints label if the user ran out
    @IBAction func hintsButtonPressed(_ sender: Any) {
        if (hintCount == totalHints && gameStarted) {
            revealHints()
        }
    }
    
    // reveals the next hint or displays no more hints if
    // the user has run out
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
    
    // reveals next hint, or if there are no more hints, 
    // it tells the user they are out of hints
    @IBAction func anotherHintButtonPressed(_ sender: Any) {
        revealHints()
    }
    
    // if the quit button is pressed, then user is taken back
    // to the map screen
    @IBAction func quitButtonPressed(_ sender: Any) {
        let title = wonGame ? "Congratulations!" : "You are attempting to leave this mini game"
        let message = wonGame ? "Let's see what you found" : "Are you sure you want to quit now?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if self.wonGame == true {
                self.performSegue(withIdentifier: "ShowLocationInfo", sender: self)
            } else {
                self.dismiss(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // pauses/plays game
    @IBAction func playButtonPressed(_ sender: Any) {
        pauseResumeGame()
    }
    
    // if the game has just started, the right VCs are displayed
    // depending on which game is being played. Also changes image
    // of pause/play button accordingly. Pauses and resumes game
    // based on response user gives to the alert. Handles timer
    func pauseResumeGame() {
        if (gameStarted == false) {
            gameStarted = true
            if (gameLocation == "Tower") {
                let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
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
    
    // shows alert prompting user to restart or resume the game
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
    
    // starts timer
    func startCountdown() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    // updates the time left and pauses timer if the user won and
    // shows alert if the user ran out of time and asks if they
    // would like to try again
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

    // updates timer label to reflect correct time
    func updateTimerLabel() {
        timerLabel.text = "Timer: \(timeLeft)s"
    }
    
    func pauseTimer() {
        timer?.invalidate() // Stop the timer
        //timer = nil // Clear the timer reference
    }
    
    // resets the whole game
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
        
        
        let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
        let instructionsVC = storyboard.instantiateViewController(withIdentifier: "GameInstructions") as? GameInstructionsViewController
        
        instructionsVC?.instructions = gameInstructions
        
        displayChildViewController(instructionsVC!)
    }
    
    // changes the Container View to display the VC that is passed in
    func changeScreen(vc: UIViewController) {
        displayChildViewController(vc)
    }
    
    // pauses the timer
    func stopsTimer() {
        pauseTimer()
    }
    
    // The user is victorious
    func didWinGame() {
        wonGame = true
        quitButton.setTitle("You Won!", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLocationInfo",
           let destinationVC = segue.destination as? LocationInfoViewController {
            if let locationCoordinates = locationCoordinates {
                destinationVC.coordinates = Coordinate(locationCoordinates)
                print("Passing coordinates: \(locationCoordinates)")
            } else {
                print("locationCoordinates is nil")
            }
            destinationVC.locationTitle = locationTitle
            print("Passing locationTitle: \(locationTitle)")
        }
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






