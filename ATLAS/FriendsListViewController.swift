//
//  FriendsListViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 11/11/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var friendsList:[String] = []
    
    var currUserID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is signed in")
            return
        }
        
        currUserID = currentUserUID
        
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(currentUserUID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists, let friends = document.data()?["friends"] as? [String] {
                    
                    let userData = document.data()
                    print("User data: \(userData ?? [:])")
                    
                    self.friendsList = friends
                    
                    for friend in self.friendsList {
                        print(friend)
                    }
                    
                    print(userData?["friends"] as? [String] ?? [])
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                } else {
                    print("User document does not exist")
                }
            }
        }
    }

    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // If user with username inputted exists, they get added to your friends list.
    // Else an alert appears asking you to try again.
    @IBAction func addFriendPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Add a Friend",
            message: "Type in a username to add a friend!",
            preferredStyle: .alert)
        
        controller.addTextField() {
            (textField) in textField.placeholder = "Friend's Username"
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default) {
                (action) in 
                let friendUser = controller.textFields![0].text
                
                let db = Firestore.firestore()
                db.collection("users").whereField("username", isEqualTo: friendUser!).getDocuments { (snapshot, error) in
                    if let error = error {
                        print("\(error.localizedDescription)")
                        return
                    }
                    
                    if let snapshot = snapshot, snapshot.isEmpty {
                        let controller = UIAlertController(title: "User does not exist.", message: "Please try a different username.", preferredStyle: .alert)
                        
                        controller.addAction(UIAlertAction(title: "OK", style: .cancel))
                        
                        self.present(controller, animated: true)
                    } else {
                        var friendData = snapshot?.documents.first?.data()
                        
                        let friendEmail = friendData!["email"] as? String
                        
                        let db = Firestore.firestore()
                            
                            // Get the current user's document reference
                        let currentUserRef = db.collection("users").document(self.currUserID)
                            
                            // Add the friend to the current user's "friends" array
                            currentUserRef.updateData([
                                "friends": FieldValue.arrayUnion([friendEmail])
                            ]) { error in
                                if let error = error {
                                    print("Error adding friend: \(error.localizedDescription)")
                                } else {
//                                    self.friendsList.append(friendEmail!)
                                    db.collection("users").document(self.currUserID).getDocument { (document, error) in
                                                if let document = document, document.exists {
                                                    if let friends = document.data()?["friends"] as? [String] {
                                                        self.friendsList = friends
                                                        print("Updated Locations: \(self.friendsList)")
                                                        DispatchQueue.main.async {
                                                            self.tableView.reloadData()
                                                        }
                                                    } else {
                                                        print("No locations field found.")
                                                    }
                                                } else {
                                                    print("Document does not exist.")
                                                }
                                            }

                                    print("Friend added successfully!")
                                }
                            }
                    }
                    
                }
                
            } )
        
        present(controller, animated: true)
    }
    
    // returns the total number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    // allows user to scroll through cells and displays the correct cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendsListTableViewCell
        let friendEmail = friendsList[indexPath.row]
        
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: friendEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
               
                let document = snapshot.documents.first!
                
                if let username = document.data()["username"] as? String, let picture = document.data()["profilePic"] as? String {
               
                    cell.configureCell(withText: username, image: picture)
                } else {
                    print("Username not found for email: \(friendEmail)")
                }
            } else {
                print("No user found with email: \(friendEmail)")
            }
        }
        
        return cell
    }
    
    // creates an animation that creates a gray flash whenever
    // a row is selected/clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // allows for pizzas to be deleted from the list and core data
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let ID = pizzaList[indexPath.row].id
//            pizzaList.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            let fetchRequest: NSFetchRequest<PizzaEntity> = PizzaEntity.fetchRequest()
//                fetchRequest.predicate = NSPredicate(format: "id == %d", ID)
//            do {
//                    let pizzaDel = try context.fetch(fetchRequest)
//                context.delete(pizzaDel.first!)
//                    saveContext()
//                } catch {
//                    print("Error fetching item: \(error)")
//                }
//        }
//    }

}


