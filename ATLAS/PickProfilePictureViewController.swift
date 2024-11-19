//
//  PickProfilePictureViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 11/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PickProfilePictureViewController: UIViewController {
    
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func blueTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "blue")
    }
    
    @IBAction func creamTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "cream")
    }
    
    @IBAction func orangeTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "orange")
    }
    
    @IBAction func grayTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "gray")
    }
    
    @IBAction func pinkTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "pink")
    }
    
    @IBAction func yellowTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "yellow")
    }
    
    @IBAction func pinkAndRedTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "pinkAndRed")
    }
    
    @IBAction func greenTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "green")
    }
    
    @IBAction func purpleAndOrangeTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "purpleAndOrange")
    }
    
    @IBAction func lightBlueTapped(recognizer:UITapGestureRecognizer) {
        storeProfilePicture(profilePic: "lightBlue")
    }
    
    func storeProfilePicture(profilePic: String) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            // Update the username field (or any other field you want)
            userRef.updateData([
                "profilePic": profilePic
            ]) { error in
                if let error = error {
                    print("Error updating user data: \(error.localizedDescription)")
                } else {
                    print("User data successfully updated!")
                    let otherVC = self.delegate as! ContainerHidder
                    
                    otherVC.hideContainerView(profilePic: profilePic)
                }
            }
        } else {
            print("couldn't authenticate user")
        }
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
