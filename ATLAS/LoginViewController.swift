//
//  LoginViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 11/5/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = ""

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        addBottomShadow(to: usernameTextField)
        addBottomShadow(to: passwordTextField)
        addBorderToButton(newAccountButton)
        
    }
    
    // adds a slight shadow to the bottom of the textfields
    func addBottomShadow(to textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)  // Only bottom shadow
        textField.layer.shadowRadius = 2
        textField.layer.masksToBounds = false // Make sure shadow is outside the bounds
    }
    
    // adds a border to the buttons
    func addBorderToButton(_ button: UIButton) {
        button.layer.borderWidth = 2  // Set border width
        button.layer.borderColor = UIColor.darkGray.cgColor  // Set border color
        button.layer.cornerRadius = 10  // Optional: rounded corners
        button.layer.masksToBounds = true  // Ensures content inside button is clipped to the corner radius
    }
    
    // allows the user to login using firebase
    @IBAction func loginPressed(_ sender: UIButton) {
        sender.isEnabled = false
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: username!, password: password!) {
            (authResult, error) in
            if let error = error as NSError? {
                self.statusLabel.text = "\(error.localizedDescription)"
            } else {
                self.statusLabel.text = ""
                
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            }
            
        }
        
        sender.isEnabled = true
    }
    
    @IBAction func forgetPasswordPressed(_ sender: Any) {
    }
    
    @IBAction func newAccountPressed(_ sender: Any) {
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
    
    // passes on the right data to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangePasswordSegue", let nextVC = segue.destination as? ForgotChangePasswordViewController {
            nextVC.prevScreen = "Login"
        }
    }
    

}
