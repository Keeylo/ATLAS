//
//  LeaderboardTableViewCell.swift
//  ATLAS
//
//  Created by Valerie Ferman on 11/23/24.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    func configureCell(withText username: String, image: String, score: Int, place: Int) {
        usernameLabel.text = username
        
        if (username == "me") {
            usernameLabel.textColor = .red
        }
        
        scoreLabel.text = String(score) + " pts"
        
        if (image == "person.circle.fill") {
            profilePicture.image = UIImage(systemName: "person.circle.fill")
            profilePicture.tintColor = .darkGray
        } else {
            profilePicture.image = UIImage(named: image)
        }
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        
        placeLabel.text = String(place)
        if (place == 1) {
            placeLabel.text = "🥇"
        } else if (place == 2) {
            placeLabel.text = "🥈"
        } else if (place == 3) {
            placeLabel.text = "🥉"
        }
        
    }

}
