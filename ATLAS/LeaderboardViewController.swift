//
//  LeaderboardViewController.swift
//  ATLAS
//
//  Created by Valerie Ferman on 12/1/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var friendsData:[FriendsData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is signed in")
            return
        }
        
        var friendsList:[String] = []
        var fetchCount = 0

        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(currentUserUID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists, let friends = document.data()?["friends"] as? [String], let picture = document.data()?["profilePic"] as? String, let score = document.data()?["score"] {
                    
                    let userData = document.data()
                    print("User data: \(userData ?? [:])")
                    
                    friendsList = friends
                    
                    for friend in friendsList {
                        print(friend)
                    }
                    
                    self.friendsData.append(FriendsData(username: "me", image: picture, score: score as! Int))
                    
                    print(userData?["friends"] as? [String] ?? [])
                    
                    for friendEmail in friendsList {
                        
                        db.collection("users").whereField("email", isEqualTo: friendEmail).getDocuments { (snapshot, error) in
                            if let error = error {
                                print("Error getting document: \(error.localizedDescription)")
                                return
                            }
                            
                            if let snapshot = snapshot, !snapshot.isEmpty {
                                
                                let document = snapshot.documents.first!
                                
                                if let username = document.data()["username"] as? String, let picture = document.data()["profilePic"] as? String, let score = document.data()["score"] {
                                    self.friendsData.append(FriendsData(username: username, image: picture, score: score as! Int))
                                } else {
                                    print("Username not found for email: \(friendEmail)")
                                }
                            } else {
                                print("No user found with email: \(friendEmail)")
                            }
                            
                            fetchCount += 1
                            
                            if fetchCount == friendsList.count {
                                self.friendsData.sort { $0.score > $1.score }
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    
                } else {
                    print("User document does not exist")
                }
            }
        }
    }
    
    // returns the total number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    // allows user to scroll through cells and displays the correct cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardTableViewCell
        let friend = friendsData[indexPath.row]

        let username = friend.username
        let picture = friend.image
        let score = friend.score
        
        cell.configureCell(withText: username, image: picture, score: score, place: (indexPath.row + 1))
        
        return cell
    }
    
    // creates an animation that creates a gray flash whenever
    // a row is selected/clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // sets height of cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65 
    }
    
    @IBAction func backToMap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    

}

struct FriendsData {
    var username: String
    var image: String
    var score: Int
}
