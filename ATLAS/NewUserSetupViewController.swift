//
//  NewUserSetupViewController.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreData

class NewUserSetupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var newUserID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = ""

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        addBottomShadow(to: emailTextField)
        addBottomShadow(to: usernameTextField)
        addBottomShadow(to: passwordTextField)
        addBottomShadow(to: confirmPasswordTextField)
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
    }
    
    // creates the new account for the user if the username is not
    // already taken, and the email has not already been used
    @IBAction func createAccountPressed(_ sender: UIButton) {
        if let email = emailTextField.text,
           let username = usernameTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           password == confirmPassword {
            
            let db = Firestore.firestore()
            db.collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error checking username availability: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // show alert that username is already taken
                    self.statusLabel.text = "Username is already taken. Please try a different one."
                    
                    return
                } else {
                    // Proceed with Firebase Authentication
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.statusLabel.text = "\(error.localizedDescription)"
                            print("Error creating user: \(error.localizedDescription)")
                            return
                        } else {
                            self.statusLabel.text = ""
                        }
                        
                        if let user = authResult?.user {
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = username
                            changeRequest.commitChanges { (error) in
                                if let error = error {
                                    print("Error setting display name: \(error.localizedDescription)")
                                } else {
                                    print("Display name set to: \(username)")
                                }
                            }
                        }
                        
                        // User was created successfully, now store the user details in Firestore
                        if let userId = authResult?.user.uid {
                            self.newUserID = userId
                            self.storeUserData(userId: userId, email: email, username: username)
                        }
                        
                        self.performSegue(withIdentifier: "CreateAccountSegue", sender: nil)
                        
                    }
                }
            }
            
        } else {
            statusLabel.text = "Passwords do not match or fields are empty."
        }
    }
    
    // stores the data for the new user in firebase
    func storeUserData(userId: String, email: String, username: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let userData: [String: Any] = [
            "email": email,
            "username": username,
            "locations": [],
            "friends": [],
            "profilePic": "person.circle.fill",
            "score": 0
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("Error storing user data: \(error.localizedDescription)")
            } else {
                print("User data stored successfully")
            }
        }
    }
    
    // adds shadow to a textfield
    func addBottomShadow(to textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 2
        textField.layer.masksToBounds = false
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
