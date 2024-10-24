//
//  UserSettingsViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserSettingsViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // shows alert that asks users if they are sure they want
    // to delete their account. If they select yes, account and
    // its data is deleted and a segue is done to the login screen
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? All progress will be lost.", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: deleteAccount(alert:)))
        
        present(controller, animated: true)
    }
    
    // deletes the users account from database and segues back to
    // the login screen
    func deleteAccount(alert: UIAlertAction) {
        // add in code for next release when firebase is connected
//        let user = Auth.auth().currentUser
//    
//        user!.delete { error in
//            if let error = error {
//                print("Error deleting user: \(error.localizedDescription)")
//            } else {
//                print("User deleted")
//            }
//        }
    
        performSegue(withIdentifier: "LoginScreenSegue", sender: self) // add segue in storyboard
    }
    
    // alert asks user if they want to sign out. If yes, they are 
    // taken to the login screen
    @IBAction func logOutPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: signOut(alert:)))
        
        present(controller, animated: true)

    }
    
    
    // if sign out fails, alert is shown that prompts the user to try again.
    // else if sign out is successful, then user is taken to login screen
    func signOut(alert: UIAlertAction) {
        // add code to next release once firebase is set up for login
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            let controller = UIAlertController(title: "Error", message: "Account deletion failed. Try again.", preferredStyle: .alert)
//    
//            controller.addAction(UIAlertAction(title: "Okay", style: .cancel))
//        }
    
        performSegue(withIdentifier: "LoginScreenSegue", sender: self) // add segue in storyboard
    }
    
    
    
    
    // add code for next release when fierbase for login has been set up and can be tested properly
//    func changeUsername(currentUser: String, newUser: String) {
//        
//        let db = Firestore.firestore()
//        
//        let userRef = db.collection("users").document(currentUser)
//        
//        userRef.updateData(["username": newUser]) { error in
//            if let error = error {
//                print("Error updating username: \(error.localizedDescription)")
//            } else {
//                print("Username updated")
//            }
//        }
//        
//    }
//    
//    func changePassword(currentPassword: String, newPassword: String) {
//        
//        let db = Firestore.firestore()
//        
//        let userRef = db.collection("users").document(currentPassword)
//        
//        userRef.updateData(["password": newPassword]) { error in
//            if let error = error {
//                print("Error updating password: \(error.localizedDescription)")
//            } else {
//                print("Password updated")
//            }
//        }
//    }
    
}
