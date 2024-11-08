//
//  NewUserSetupViewController.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewUserSetupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var shouldLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = ""

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        addBottomShadow(to: usernameTextField)
        addBottomShadow(to: passwordTextField)
        addBottomShadow(to: confirmPasswordTextField)
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        if let username = usernameTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           password == confirmPassword {
            // Proceed with Firebase Authentication
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    self.shouldLogin = false
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
                    self.storeUserData(userId: userId, username: username)
                }
                
                self.shouldLogin = true
            }
        } else {
            statusLabel.text = "Passwords do not match or fields are empty."
        }
    }
    
    func storeUserData(userId: String, username: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        
        let userData: [String: Any] = [
            "username": username,
            "locations": []
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
    
    // checks if segue can be performed
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "CreateAccountSegue" {
            return shouldLogin
        }
        
        return true
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
