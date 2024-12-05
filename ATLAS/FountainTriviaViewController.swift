//
//  FountainTriviaViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 12/4/24.
//

import UIKit

class FountainTriviaViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerOneButton: UIButton!
    @IBOutlet weak var answerTwoButton: UIButton!
    @IBOutlet weak var answerThreeButton: UIButton!
    @IBOutlet weak var answerFourButton: UIButton!
    
    var answerOneCorrect = false
    var answerTwoCorrect = true
    var answerFourCorrect = false
    
    var delegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionLabel.text = "What is the Littlefield Fountain statue of?"
        
        answerOneButton.setTitle("UT Tower", for: .normal)
        answerTwoButton.setTitle("Ship with horses", for: .normal)
        answerThreeButton.setTitle("Bevo", for: .normal)
        answerFourButton.setTitle("Austin Skyline", for: .normal)
        
    }
    
    @IBAction func answerOnePressed(_ sender: Any) {
        
        if (answerOneCorrect) {
            answerOneCorrect = false
            answerFourCorrect = true
            
            nextQuestion(question: "What material is the fountain's statue made out of?", answerOne: "Gold", answerTwo: "Silver", answerThree: "Copper", answerFour: "Bronze")
            
        } else {
            answerOneButton.backgroundColor = .red
            wrongAnswerChosen()
        }
        
    }
    
    @IBAction func answerTwoPressed(_ sender: Any) {
        
        if (answerTwoCorrect) {
            answerTwoCorrect = false
            answerOneCorrect = true
            
            nextQuestion(question: "How many levels does the fountain have?", answerOne: "Three", answerTwo: "One", answerThree: "Four", answerFour: "Two")
        } else {
            answerTwoButton.backgroundColor = .red
        }
        
    }
    
    @IBAction func answerThreePressed(_ sender: Any) {
        answerOneButton.backgroundColor = .red
        wrongAnswerChosen()
    }
    
    @IBAction func answerFourPressed(_ sender: Any) {
        
        if (answerFourCorrect) {
            let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
            let winnerVC = storyboard.instantiateViewController(withIdentifier: "WonGame") as? WonGameViewController
            
            let otherVC = delegate as! ScreenChanger
            otherVC.changeScreen(vc: winnerVC!)
            
            let otherVC2 = delegate as! TimerStops
            otherVC2.stopsTimer()
            
            let otherVC3 = delegate as! GameWon
            otherVC3.didWinGame()
        } else {
            answerFourButton.backgroundColor = .red
        }
    }
    
    func nextQuestion(question: String, answerOne: String, answerTwo: String, answerThree: String, answerFour: String) {
        questionLabel.text = question
        answerOneButton.setTitle(answerOne, for: .normal)
        answerTwoButton.setTitle(answerTwo, for: .normal)
        answerThreeButton.setTitle(answerThree, for: .normal)
        answerFourButton.setTitle(answerFour, for: .normal)
    }
    
    func wrongAnswerChosen() {
        let otherVC = delegate as! TimerStops
        otherVC.stopsTimer()
        
        let controller = UIAlertController(title: "Wrong Answer!", message: "You lost the game. Press 'Restart' to restart the game, or 'Quit' to quit.", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Quit", style: .default, handler: { (action: UIAlertAction!) in
            let otherVC = self.delegate as! GameDismisser
            otherVC.dismissGame()
        }))
        controller.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (action: UIAlertAction!) in
            let otherVC = self.delegate as! GameResetter
            otherVC.resetGame()
        }))
        
        present(controller, animated: true)
    }
    
    

}
