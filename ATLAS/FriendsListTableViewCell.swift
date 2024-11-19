//
//  FriendsListTableViewCell.swift
//  ATLAS
//
//  Created by Valerie Ferman on 11/11/24.
//

import UIKit

class FriendsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var friendsUsernameLabel: UILabel!
    
    // set the image and label data
    func configureCell(withText text: String, image: String) {
        friendsUsernameLabel.text = text
        if (image == "person.circle.fill") {
            profilePicture.image = UIImage(systemName: "person.circle.fill")
            profilePicture.tintColor = .darkGray
        } else {
            profilePicture.image = UIImage(named: image)
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
