//
//  PCLGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 12/6/24.
//

import UIKit

struct Book {
    var bookName: String
    var fiction: Bool
}

class PCLGameViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var fictionView: UIView!
    @IBOutlet weak var nonFictionView: UIView!
    
    @IBOutlet weak var bookImage: UIImageView!
    
//    var harryPotter: UIImageView!
//    var darkMatter: UIImageView!
//    var breath: UIImageView!
//    var janeEyre: UIImageView!
//    var iOSBook: UIImageView!
//    var michelle: UIImageView!
//    var warriorCats: UIImageView!
//    var jennette: UIImageView!
//    var immenseWorld: UIImageView!
//    var lifeOfPi: UIImageView!
    
    var delegate: UIViewController!
    
    var books = [Book(bookName: "harryPotter", fiction: true), Book(bookName: "darkMatter", fiction: true), Book(bookName: "breath", fiction: false), Book(bookName: "janeEyre", fiction: true), Book(bookName: "iOS_Book", fiction: false), Book(bookName: "michelleObama", fiction: false), Book(bookName: "warriorCats", fiction: true), Book(bookName: "jennette", fiction: false), Book(bookName: "immenseWorld", fiction: false), Book(bookName: "lifeOfPi", fiction: true)]
    var booksIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImage.alpha = 0.8
        
        bookImage.image = UIImage(named: books[booksIndex].bookName)
        bookImage.layer.borderWidth = 1
        bookImage.layer.borderColor = UIColor(.black).cgColor
        
        bookImage.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(recognizer: )))
        bookImage.addGestureRecognizer(panGesture)
        
        fictionView.layer.borderWidth = 2
        fictionView.layer.borderColor = UIColor(.black).cgColor
        
        nonFictionView.layer.borderWidth = 2
        nonFictionView.layer.borderColor = UIColor(.black).cgColor
        
    }

    // If a book is dragged to the right box, it's hidden and the
    // imageview is reset to be the next book and back to the original
    // spot. If a book is dragged to the wrong box, the game is over
    @IBAction func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        
        var newX = bookImage.center.x + translation.x
        var newY = bookImage.center.y + translation.y
        
        let backgroundBounds = backgroundImage.frame
        
        newX = max(backgroundBounds.minX + bookImage.frame.width / 2, min(backgroundBounds.maxX - bookImage.frame.width / 2, newX))
                
                // Constrain the y-coordinate (top and bottom limits)
        newY = max(backgroundBounds.minY + bookImage.frame.height / 2, min(backgroundBounds.maxY - bookImage.frame.height / 2, newY))
        
        if let view = recognizer.view {
            view.center = CGPoint(x: newX, y: newY)
        }
        
        recognizer.setTranslation(.zero, in: self.view)
        
        if (recognizer.state == .ended) {
            if ((recognizer.view!.frame).intersects(fictionView.frame) || (recognizer.view!.frame).intersects(nonFictionView.frame)) {
                if (recognizer.view!.frame).intersects(fictionView.frame) {
                    if (!books[booksIndex].fiction) {
                        wrongAnswer()
                        return
                    }
                } else if (recognizer.view!.frame).intersects(nonFictionView.frame) {
                    if (books[booksIndex].fiction) {
                        wrongAnswer()
                        return
                    }
                }
                
                recognizer.view!.isHidden = true
                booksIndex += 1
                
                sleep(UInt32(0.5))
                
                if (booksIndex == books.count) {
                    let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
                    let winnerVC = storyboard.instantiateViewController(withIdentifier: "WonGame") as? WonGameViewController
                    
                    let otherVC = delegate as! ScreenChanger
                    otherVC.changeScreen(vc: winnerVC!)
                    
                    let otherVC2 = delegate as! TimerStops
                    otherVC2.stopsTimer()
                    
                    let otherVC3 = delegate as! GameWon
                    otherVC3.didWinGame()
                    
                    return
                }
                
                resetBookImage(book: recognizer.view as! UIImageView)
            }
        }
    }
    
    // resets the position of the book UIImageView and replaces the image
    // with the next book
    func resetBookImage(book: UIImageView) {
        book.image = UIImage(named: books[booksIndex].bookName)
        book.frame = CGRect(x: (backgroundImage.bounds.width - 118) / 2,
                                 y: backgroundImage.frame.maxY - 160 - 20,
                                 width: 118, height: 160)
        
        book.isHidden = false
    }
    
    // if user sorts a book wrong, then the game ends and they are prompted
    // to restart or quit the game
    func wrongAnswer() {
        
        bookImage.layer.borderColor = UIColor(.red).cgColor
        
        let otherVC = delegate as! TimerStops
        otherVC.stopsTimer()
        
        sleep(UInt32(0.5))
        
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
