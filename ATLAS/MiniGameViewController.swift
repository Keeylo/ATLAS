//
//  MiniGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/15/24.
//

import UIKit

class MiniGameViewController: UIViewController {

    @IBOutlet weak var controllerView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pausePlayButton: UIButton!

    @IBOutlet weak var givenHints: UILabel!
    @IBOutlet weak var hintsButton: UIButton!
    @IBOutlet weak var outOfHintsLabel: UILabel!
    
    var hints1: String = ""
    var hints2: String = ""
    var hints3: String = ""
    var hintCount = 3
    
    var timer: Timer?
    var timeLeft: Int = 60
    var timerPaused: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        
        timerLabel.text = ""
        
        givenHints.text = ""
        givenHints.sizeToFit()
        givenHints.text = """
            hint 1
            hint 2
            hint 3
        """
        outOfHintsLabel.isHidden = true
        
    }
    
    @IBAction func hintsButtonPressed(_ sender: Any) {
        if (hintCount > 0) {
            
        } else {
            
        }
        hintCount -= 1
    }
    
    // if the quit button is pressed, then user is taken back to the map screen
    @IBAction func quitGameButtonPressed(_ sender: Any) {
        // add segue after pulling code
    }
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        timerPaused.toggle()
        if let currentImage = pausePlayButton.image(for: .normal) {
            if currentImage.isEqual(UIImage(systemName: "pause.fill")) {
                pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                pauseTimer()
            } else if currentImage.isEqual(UIImage(systemName: "play.fill")) {
                startCountdown()
                pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
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
            
            print("Time's up!")
        }
    }

    func updateTimerLabel() {
        timerLabel.text = "Timer: \(timeLeft)s"
    }
    
    func pauseTimer() {
            timer?.invalidate() // Stop the timer
            timer = nil // Clear the timer reference
        }
    

}
