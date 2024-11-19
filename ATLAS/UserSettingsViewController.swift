//
//  UserSettingsViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 10/23/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol ContainerHidder {
    func hideContainerView(profilePic: String)
}

class UserSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ContainerHidder {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var profilePicView: UIView!
    
    
    let picker = UIImagePickerController()
    
    var newUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicView.layer.cornerRadius = 10
        profilePicView.layer.borderWidth = 2
        profilePicView.layer.borderColor = UIColor.darkGray.cgColor
        profilePicView.layer.shadowColor = UIColor.black.cgColor
        profilePicView.layer.shadowOffset = CGSize(width: 0, height: 2)
        profilePicView.layer.shadowRadius = 4
        profilePicView.layer.shadowOpacity = 0.5
        profilePicView.clipsToBounds = true
        profilePicView.isHidden = true
        
        if let profilePicVC = children.first as? PickProfilePictureViewController {
            profilePicVC.delegate = self
        }
        
        picker.delegate = self

        newUsername = ""
        
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            usernameLabel.text = user.displayName
            
            var userID = user.uid
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userID)
            
            // Get the user's profile image URL from Firestore
            userRef.getDocument { (document, error) in
                if let error = error {
                    print("Error getting user document: \(error.localizedDescription)")
                    return
                }
                
                let data = document!.data()
                print("User data: \(data ?? [:])")
                
                if let document = document, document.exists {
                    // Get the image URL from the document
                    if let profilePic = document.data()?["profilePic"] as? String {
                        
//                        let storageRef = Storage.storage().reference(forURL: profileImageUrl)
//                        
//                        // Download the image
//                        storageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
//                            if let error = error {
//                                print("Error downloading image: \(error.localizedDescription)")
//                                return
//                            }
//                            
//                            if let data = data {
//                                // Set the image in the UIImageView
//                                if let image = UIImage(data: data) {
//                                    self.profilePicture.image = image
//                                }
//                            }
//                        }
                        if (profilePic == "person.circle.fill") {
                            self.profilePicture.image = UIImage(systemName: "person.circle.fill")
                        } else {
                            self.profilePicture.image = UIImage(named: profilePic)
                        }
                        
                    } else {
                        print("No profile image URL found")
                    }
                } else {
                    print("User document does not exist - 0")
                }
            }
            
        } else {
            print("Current user could not be authenticated")
        }
        
        
        
        passwordLabel.text = String(repeating: "•", count: 10)
        
        profilePicture.frame = CGRect(x: 105, y: 134, width: 170, height: 170)
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        
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
    
    // allows user to change their profile picture
    @IBAction func changeProfilePicture(_ sender: Any) {
        
//        picker.sourceType = .photoLibrary
//        picker.allowsEditing = false
//        present(picker, animated: true)
        
        profilePicView.isHidden = false
    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        let chosenImage = info[.originalImage] as! UIImage
//        
//        profilePicture.contentMode = .scaleAspectFill
//        
//        profilePicture.image = chosenImage
//        
//        dismiss(animated: true)
//        
//        storeImage(image: chosenImage)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        print("User cancelled selecting profile picture")
//        dismiss(animated: true)
//    }
//    
//    func storeImage(image: UIImage) {
//        let imageName = UUID().uuidString
//        let storageRef = Storage.storage().reference().child("/profile_images").child("\(imageName).jpg")
//        
//        // convert image
//        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
//                print("Error converting image to data")
//                return
//            }
//        
//        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
//                if let error = error {
//                    print("Error uploading image: \(error.localizedDescription)")
//                    return
//                }
//                
//                // Once the upload is complete, get the download URL
//                storageRef.downloadURL { (url, error) in
//                    if let error = error {
//                        print("Error getting download URL: \(error.localizedDescription)")
//                        return
//                    }
//                    
//                    // If successful, save the image URL in Firestore
//                    if let downloadURL = url {
//                        guard let userID = Auth.auth().currentUser?.uid else {
//                            print("User is not logged in.")
//                            return
//                        }
//                        
//                        let db = Firestore.firestore()
//                        let userRef = db.collection("users").document(userID)
//                        
//                        // Update the user's profile with the new image URL
//                        userRef.updateData([
//                            "profilePicURL": downloadURL.absoluteString
//                        ]) { error in
//                            if let error = error {
//                                print("Error saving URL to Firestore: \(error.localizedDescription)")
//                            } else {
//                                print("Image URL saved successfully to Firestore.")
//                            }
//                        }
//                    }
//                }
//            }
//    }
    
    // changes the username visually and in firebase
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
    
    func hideContainerView(profilePic: String) {
        profilePicture.image = UIImage(named: profilePic)
        profilePicView.isHidden = true
    }
    
}
