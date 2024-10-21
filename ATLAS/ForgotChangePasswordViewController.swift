//
//  ForgotChangePasswordViewController.swift
//  ATLAS
//
//  Created by Savindu Wimalasooriya on 10/21/24.
//

import UIKit

class ForgotChangePasswordViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        guard let email = usernameTextField.text,
              let oldPassword = oldPasswordTextField.text,
              let newPassword = newPasswordTextField.text,
              !email.isEmpty, !oldPassword.isEmpty, !newPassword.isEmpty else {
            print("Please fill in all fields")
            return
        }

        // Re-authenticate the user with the old password
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                // Handle authentication failure (wrong old password, etc.)
                print("Error re-authenticating: \(error.localizedDescription)")
            } else {
                // Authentication succeeded, now update the password
                user?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        // Handle failure to update password
                        print("Error updating password: \(error.localizedDescription)")
                    } else {
                        // Password updated successfully
                        print("Password successfully updated")
                    }
                }
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
