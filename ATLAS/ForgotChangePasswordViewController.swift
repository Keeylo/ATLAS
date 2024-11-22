//
//  ForgotChangePasswordViewController.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 10/21/24.
//

import UIKit
import FirebaseAuth

class ForgotChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var prevScreen = ""
    var shouldLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statusLabel.text = ""
        
        usernameTextField.delegate = self
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        
        addBottomShadow(to: usernameTextField)
        addBottomShadow(to: oldPasswordTextField)
        addBottomShadow(to: newPasswordTextField)
        
        oldPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.isSecureTextEntry = true
        
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        guard let email = usernameTextField.text,
              let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              !email.isEmpty, !oldPassword.isEmpty, !newPassword.isEmpty else {
            self.statusLabel.text = "Please fill in all fields"
            self.shouldLogin = false
            
            return
        }

        // Re-authenticate the user with the old password
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                self.statusLabel.text = "\(error.localizedDescription)"
                // Handle authentication failure (wrong old password, etc.)
                print("Error re-authenticating: \(error.localizedDescription)")
            } else {
                // Authentication succeeded, now update the password
                user?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        self.statusLabel.text = "\(error.localizedDescription)"
                        self.shouldLogin = false
                        // Handle failure to update password
                        print("Error updating password: \(error.localizedDescription)")
                    } else {
                        // Password updated successfully
                        self.shouldLogin = true
                        self.statusLabel.text = "Password successfully updated"
                    }
                }
            }
        }
    }
    
    // segues back to original screen, login or settings
    @IBAction func backButtonPressed(_ sender: Any) {
        print("in back")
        if (prevScreen == "Login") {
            performSegue(withIdentifier: "PasswordToLoginSegue", sender: self)
        } else if (prevScreen == "Settings") {
            performSegue(withIdentifier: "PasswordToSettingsSegue", sender: self)
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
        
        if identifier == "ChangePasswordSegue" {
            return shouldLogin
        }
        
        return true
    }
    
    
    // ADD KEYBOARD CODE LATER
    
//    // Called when 'return' key pressed
//    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//        
//    // Called when the user clicks on the view outside of the UITextField
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }

}
