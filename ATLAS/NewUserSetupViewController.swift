//
//  NewUserSetupViewController.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 10/21/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewUserSetupViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        if let username = usernameTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text,
           password == confirmPassword {
            // Proceed with Firebase Authentication
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                    return
                }
                // User was created successfully, now store the user details in Firestore
                if let userId = authResult?.user.uid {
                    self.storeUserData(userId: userId, username: username)
                }
            }
        } else {
            print("Passwords do not match or fields are empty.")
        }
    }
    
    func storeUserData(userId: String, username: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["username": username]) { error in
            if let error = error {
                print("Error storing user data: \(error.localizedDescription)")
            } else {
                print("User data stored successfully")
            }
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
