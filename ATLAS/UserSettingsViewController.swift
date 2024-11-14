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
            
//            print(user.displayName)
        } else {
            print("...00" )
        }
        
        
        
        passwordLabel.text = String(repeating: "•", count: 10)
        
        
    }
    
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // adds shadow to a textfield
    func addBottomShadow(to textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 2
        textField.layer.masksToBounds = false
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
        let user = Auth.auth().currentUser
    
        user!.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User deleted")
            }
        }
    
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
        do {
            try Auth.auth().signOut()
        } catch {
            let controller = UIAlertController(title: "Error", message: "Account deletion failed. Try again.", preferredStyle: .alert)
    
            controller.addAction(UIAlertAction(title: "Okay", style: .cancel))
        }
    
        performSegue(withIdentifier: "LoginScreenSegue", sender: self) // add segue in storyboard
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        
    }
    
    @IBAction func changeUsernamePressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Change Username",
            message: "Enter your new username.",
            preferredStyle: .alert)
        
        controller.addTextField() {
            (textField) in textField.placeholder = "New Username"
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default) {
                (action) in let enteredText = controller.textFields![0].text
                self.changeUsername(newUsername: enteredText!)
                print(enteredText!)
            } )
        
//        let okAction = UIAlertAction(
//            title: "OK",
//            style: .default) {
//            (action) in
//            
//            if let inputText = controller.textFields?.first?.text, self.checkEmail(email:inputText) {
//                self.changeUsername(newUsername: inputText)
//            }
//            
//        }
//        
//        okAction.isEnabled = false
//        
//        controller.textFields?.first?.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
//        
//        controller.addAction(okAction)
        
        present(controller,animated:true)
    }
    
//    @objc func textFieldChanged(_ textField: UITextField) {
//        if let alert = presentedViewController as? UIAlertController,
//           let okAction = alert.actions.first(where: { $0.title == "OK" }) {
//            okAction.isEnabled = checkEmail(email: textField.text ?? "")
//        }
//    }
    
//    func checkEmail(email: String) -> Bool {
//        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
//            
//        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        
//        return emailTest.evaluate(with: email)
//    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
    }
    
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
    
    func changeUsername(newUsername: String) {
        let db = Firestore.firestore()
        guard let user = Auth.auth().currentUser else {
            print("current user error")
            return
        }
        
        db.collection("users").whereField("username", isEqualTo: newUsername).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking username availability: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                // show alert that username is already taken
                let controller = UIAlertController(
                    title: "Error",
                    message: "That username is already taken. Please choose a different username.",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self.present(controller,animated:true)
                
                return
            }
            
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newUsername
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating username: \(error.localizedDescription)")
                    return
                    // You can show an alert if you need
                }
                
                print("Username updated successfully")
                
                let userRef = db.collection("users").document(user.uid)
                userRef.updateData(["username": newUsername]) { error in
                    if let error = error {
                        print("Error updating username: \(error.localizedDescription)")
                    } else {
                        print("Username updated")
                        
                        let user = Auth.auth().currentUser
                        
                        user?.reload(completion: { (error) in
                                if let error = error {
                                    print("Error reloading user profile: \(error.localizedDescription)")
                                } else {
                                    
//                                    user?.updateEmail(to: newUsername) { error in
//                                        if let error = error {
//                                            print("Error updating email: \(error.localizedDescription)")
//                                        } else {
//                                            print("email officially changed")
//                                        }
//                                        
//                                        
//                                    
//                                    }
                                    
                                    print("User profile reloaded, new displayName: \(Auth.auth().currentUser?.displayName ?? "")")
                                }
                            })
                        
                        self.usernameLabel.text = newUsername
                    }
                }
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToChangePasswordSegue", let nextVC = segue.destination as? ForgotChangePasswordViewController {
            nextVC.prevScreen = "Settings"
        }
    }
    
}
