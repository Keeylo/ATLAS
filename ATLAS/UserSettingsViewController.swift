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
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    var newUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newUsername = ""
        
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            usernameLabel.text = user.displayName
        } else {
            print("Error: No current user.")
        }
        
        // Display dummy password (hidden for security)
        passwordLabel.text = String(repeating: "•", count: 10)
    }
    
    // Log Out functionality
    @IBAction func logOutPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.signOut()
        }))
        
        present(controller, animated: true)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "LoginScreenSegue", sender: self)
        } catch {
            let errorAlert = UIAlertController(title: "Error", message: "Sign out failed. Try again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Okay", style: .default))
            present(errorAlert, animated: true)
        }
    }
    
    // Delete Account functionality
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? All progress will be lost.", preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        
        present(controller, animated: true)
    }

    func deleteAccount() {
        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "Error", message: "Account deletion failed. Try again.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(errorAlert, animated: true)
            } else {
                print("User deleted")
                self.performSegue(withIdentifier: "LoginScreenSegue", sender: self)
            }
        }
    }
    
    // Change Username functionality
    @IBAction func changeUsernamePressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Change Username",
            message: "Enter your new username.",
            preferredStyle: .alert)
        
        controller.addTextField { textField in
            textField.placeholder = "New Username"
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let enteredText = controller.textFields?.first?.text, !enteredText.isEmpty {
                self.changeUsername(newUsername: enteredText)
            }
        }))
        
        present(controller, animated: true)
    }

    func changeUsername(newUsername: String) {
        let db = Firestore.firestore()
        guard let user = Auth.auth().currentUser else {
            print("Error: No current user.")
            return
        }
        
        // Check if the username is already taken
        db.collection("users").whereField("username", isEqualTo: newUsername).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking username availability: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "That username is already taken. Please choose a different username.",
                    preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            } else {
                // Update username in Firebase Auth and Firestore
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = newUsername
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating username: \(error.localizedDescription)")
                    } else {
                        print("Username updated successfully")
                        self.usernameLabel.text = newUsername
                        db.collection("users").document(user.uid).updateData(["username": newUsername])
                    }
                }
            }
        }
    }

    // Change Password functionality
    @IBAction func changePasswordPressed(_ sender: Any) {
        let controller = UIAlertController(
                title: "Change Password",
                message: "Enter your new password and confirm it.",
                preferredStyle: .alert)
            
            // Add a text field for the new password
            controller.addTextField { textField in
                textField.placeholder = "New Password"
                textField.isSecureTextEntry = true // Hide password input
            }
            
            // Add a text field for confirming the new password
            controller.addTextField { textField in
                textField.placeholder = "Confirm New Password"
                textField.isSecureTextEntry = true // Hide password input
            }
            
            // Cancel action
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // OK action to validate and update the password
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let newPassword = controller.textFields?[0].text
                let confirmPassword = controller.textFields?[1].text
                
                if newPassword == confirmPassword, let newPassword = newPassword, !newPassword.isEmpty {
                    self.updatePassword(newPassword: newPassword)
                } else {
                    // Show error if passwords don’t match or if fields are empty
                    let errorAlert = UIAlertController(title: "Error", message: "Passwords do not match or are empty. Please try again.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }))
            
            present(controller, animated: true)
    }
    
    func updatePassword(newPassword: String) {
        // Ensure there’s a logged-in user
        guard let user = Auth.auth().currentUser else {
            print("Error: No current user.")
            return
        }
        
        // Update the password in Firebase
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error updating password: \(error.localizedDescription)")
                let errorAlert = UIAlertController(title: "Error", message: "Password update failed. Please try again.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
            } else {
                print("Password updated successfully")
                let successAlert = UIAlertController(title: "Success", message: "Your password has been updated.", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(successAlert, animated: true)
            }
        }
    }
    
    // Change Profile Picture functionality (currently empty)
    @IBAction func changeProfilePicture(_ sender: Any) {
        // Add code to handle profile picture change if needed
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChangePasswordSegue", let nextVC = segue.destination as? ForgotChangePasswordViewController {
            nextVC.prevScreen = "Settings"
        }
    }
}
