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
//                            var imageURL = self.addProfilePicture() { (imageURL) in
//                                self.storeUserData(userId: userId, email: email, username: username, imageURL: imageURL!)
//                            }
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
    
//    // creates default image for no profile picture
//    func defaultProfilePicture() -> UIImage {
//        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular, scale: .default)
//        guard let defaultImage = UIImage(systemName: "person.circle.fill", withConfiguration: config) else {
//            print("could not create default image")
//            return UIImage()
//        }
//        print("default image successful")
//        return defaultImage
//    }
//    
//    func addProfilePicture(completion: @escaping (String?) -> Void) {
//        let storageRef = Storage.storage().reference()
//        let defaultImage = defaultProfilePicture()
//
//        // Convert the UIImage to data
//        guard let imageData = defaultImage.jpegData(compressionQuality: 0.75) else {
//            print("image could not be converted")
//            completion(nil)
//            return
//        }
//        
//        let fileName = "\(newUserID).jpg"
//        
//        // Create a unique path for the image in Firebase Storage (e.g., "profile_images/{userId}.jpg")
//        guard let profileImageRef = storageRef.child("profile_images/\(fileName)") else {
//            
//        }
//        // Upload the image data to Firebase Storage
//        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                // Handle error during upload
//                if let nsError = error as NSError? {
//                    print("157 Error uploading default profile image: \(nsError.localizedDescription)")
//                    print("158 Error code: \(nsError.code), domain: \(nsError.domain)")
//                } else {
//                    print("160 Error uploading default profile image: \(error.localizedDescription)")
//                }
//                completion(nil)
//                return
//            }
//            
//            // Get the download URL for the uploaded image
//            profileImageRef.downloadURL { (url, error) in
//                if let error = error {
//                    if let nsError = error as NSError? {
//                        print("170 Error uploading default profile image: \(nsError.localizedDescription)")
//                        print("Error code: \(nsError.code), domain: \(nsError.domain)")
//                    } else {
//                        print("173 Error uploading default profile image: \(error.localizedDescription)")
//                    }
//                    completion(nil)
//                }
//                
//                if let downloadURL = url {
//                    print("url for image was created: \(downloadURL.absoluteString)")
//                    completion(downloadURL.absoluteString)
//                } else {
//                    print("error getting download url")
//                    completion(nil)
//                }
//            }
//        }
//    }
    
    
    
    // adds shadow to a textfield
    func addBottomShadow(to textField: UITextField) {
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.3
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 2
        textField.layer.masksToBounds = false
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
