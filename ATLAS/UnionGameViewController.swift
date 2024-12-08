//
//  UnionGameViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 12/6/24.
//

import UIKit

class Card {
    var cardImage: UIImageView
    var number: Int
    var facedDown: Bool
    var matched: Bool
    var red: Bool
    var label: UILabel
    
    init(cardImage: UIImageView, number: Int, facedDown: Bool, matched: Bool, red: Bool, label: String) {
        self.cardImage = cardImage
        self.number = number
        self.facedDown = facedDown
        self.matched = matched
        self.red = red
        
        let cardLabel = UILabel()
        cardLabel.frame = CGRect(x: 0, y: 0, width: 63, height: 80)
        cardLabel.text = label
        cardLabel.numberOfLines = 0
        cardLabel.textAlignment = .center
        cardLabel.font = UIFont.boldSystemFont(ofSize: 13)
        cardLabel.center = CGPoint(x: cardImage.bounds.midX, y: cardImage.bounds.midY)
        cardImage.addSubview(cardLabel)
        
        cardLabel.isHidden = true
        
        self.label = cardLabel
    }
}

class UnionGameViewController: UIViewController {
    
    @IBOutlet weak var card1: UIImageView!
    @IBOutlet weak var card2: UIImageView!
    @IBOutlet weak var card3: UIImageView!
    @IBOutlet weak var card4: UIImageView!
    @IBOutlet weak var card5: UIImageView!
    @IBOutlet weak var card6: UIImageView!
    @IBOutlet weak var card7: UIImageView!
    @IBOutlet weak var card8: UIImageView!
    @IBOutlet weak var card9: UIImageView!
    @IBOutlet weak var card10: UIImageView!
    @IBOutlet weak var card11: UIImageView!
    @IBOutlet weak var card12: UIImageView!
    
    var cards: [Card] = []
    var flippedCards: [Card] = []
    
    var unmatchedPairs = 6
    
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        cards = [Card(cardImage: card1, number: 1, facedDown: true, matched: false, red: true, label: "Stadium"), Card(cardImage: card2, number: 2, facedDown: true, matched: false, red: false, label: "Union"), Card(cardImage: card3, number: 3, facedDown: true, matched: false, red: true, label: "Tower"), Card(cardImage: card4, number: 4, facedDown: true, matched: false, red: false, label: "Stadium"), Card(cardImage: card5, number: 5, facedDown: true, matched: false, red: false, label: "Jester"), Card(cardImage: card6, number: 6, facedDown: true, matched: false, red: true, label: "Littlefield Fountain"), Card(cardImage: card7, number: 7, facedDown: true, matched: false, red: false, label: "Union"), Card(cardImage: card8, number: 8, facedDown: true, matched: false, red: true, label: "Jester"), Card(cardImage: card9, number: 9, facedDown: true, matched: false, red: true, label: "Littlefield Fountain"), Card(cardImage: card10, number: 10, facedDown: true, matched: false, red: false, label: "Tower"), Card(cardImage: card11, number: 11, facedDown: true, matched: false, red: true, label: "PCL"), Card(cardImage: card12, number: 12, facedDown: true, matched: false, red: false, label: "PCL")]
        
        addTapGestures()
        
    }
    
    // adds tap gestures for each card
    func addTapGestures() {
        for card in cards {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer: )))
            card.cardImage.isUserInteractionEnabled = true
            card.cardImage.addGestureRecognizer(tapGesture)
        }
    }
    
    // when a card is tapped, it flips to the other side
    @IBAction func handleTapGesture(recognizer: UITapGestureRecognizer) {
        
        var cardImage = recognizer.view as! UIImageView
        
        for currCard in cards {
            if (currCard.cardImage.isEqual(cardImage)) {
                let card = currCard
                if (card.matched) {
                    print("should not flip")
                    return
                }
                if (flippedCards.count == 2) {
                    if (flippedCards[0].number != card.number && flippedCards[1].number != card.number) {
                        return
                    }
                }
                
                changeCard(card: card)
            }
        }
    }
    
    //
    func changeCard(card: Card) {
        
        let angle: CGFloat = .pi
        
        let rotationTransform = CATransform3DMakeRotation(angle, 0, 1, 0)
        
        let cardImage = card.cardImage
        
        cardImage.bringSubviewToFront(card.label)
        
        DispatchQueue.main.async {
            
            UIView.animate(withDuration: 0.3, animations: {
                cardImage.layer.transform = rotationTransform
                
            }, completion: { _ in
                
                var picName = ""
                
                if (!card.facedDown) {
                    if (card.red) {
                        picName = "redCard"
                    } else {
                        picName = "blueCard"
                    }
                    card.label.isHidden = true
                    card.facedDown = true
                } else {
                    picName = "blankCard"
                    card.label.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                    card.label.isHidden = false
                    card.facedDown = false
                }
                
                cardImage.image = UIImage(named: picName)
                
                if (!card.facedDown) {
                    if (!self.flippedCards.isEmpty) {
                        if ((self.flippedCards.first?.label.text == card.label.text)  && (self.flippedCards.first?.number != card.number)) {
                            self.flippedCards.first?.matched = true
                            self.flippedCards.first?.label.textColor = .green
                            card.matched = true
                            card.label.textColor = .green
                            self.flippedCards.removeAll()
                            self.unmatchedPairs -= 1
                            
                            if (self.unmatchedPairs == 0) {

                                
                                let storyboard = UIStoryboard(name: "MiniGameStoryboard", bundle: nil)
                                let winnerVC = storyboard.instantiateViewController(withIdentifier: "WonGame") as? WonGameViewController
                                
                                sleep(UInt32(0.3))
                                
                                let otherVC = self.delegate as! ScreenChanger
                                otherVC.changeScreen(vc: winnerVC!)
                                
                                let otherVC2 = self.delegate as! TimerStops
                                otherVC2.stopsTimer()
                                
                                let otherVC3 = self.delegate as! GameWon
                                otherVC3.didWinGame()
                            }
                        } else {
                            self.flippedCards.append(card)
                        }
                    } else {
                        self.flippedCards.append(card)
                    }
                } else {
                    var index = 0
                    for flippedCard in self.flippedCards {
                        if (self.flippedCards[index].number == card.number) {
                            self.flippedCards.remove(at: index)
                            return
                        }
                        index += 1
                    }
                }
                
            })
        }
    }

}
