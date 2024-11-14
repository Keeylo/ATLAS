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
                if let document = document, document.exists, let friendsList = document.data()?["friends"] as? [String] {
                    
                    let userData = document.data()
                    print("User data: \(userData ?? [:])")
                    
                    for friend in friendsList {
                        print(friend)
                    }
                    
                    print("pop")
                    print(userData?["friends"] as? [String] ?? [])
                    
                    self.friendsList = userData?["friends"] as? [String] ?? []
                    
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
                        
                        let friendUsername = friendData!["username"] as? String
                        
                        let db = Firestore.firestore()
                            
                            // Get the current user's document reference
                        let currentUserRef = db.collection("users").document(self.currUserID)
                            
                            // Add the friend to the current user's "friends" array
                            currentUserRef.updateData([
                                "friends": FieldValue.arrayUnion([friendUsername])
                            ]) { error in
                                if let error = error {
                                    print("Error adding friend: \(error.localizedDescription)")
                                } else {
                                    self.friendsList.append(friendUsername!)
                                    DispatchQueue.main.async {
                                        self.tableView.reloadData()
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
        let friendsUsername = friendsList[indexPath.row]
        cell.configureCell(withText: friendsUsername, image: nil)
        
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


