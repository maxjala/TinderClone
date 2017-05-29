//
//  MatchesViewController.swift
//  TinderClone
//
//  Created by Max Jala on 29/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase

class MatchesViewController: UIViewController{

    @IBOutlet weak var matchesTableView: UITableView! {
        didSet {
            matchesTableView.delegate = self
            matchesTableView.dataSource = self
            matchesTableView.register(MatchTableViewCell.cellNib, forCellReuseIdentifier: MatchTableViewCell.cellIdentifier)
            
            matchesTableView.estimatedRowHeight = 80
            matchesTableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    @IBOutlet weak var goBackButton: UIButton! {
        didSet {
            goBackButton.addTarget(self, action: #selector(goBackButtonTapped), for: .touchUpInside)
            goBackButton.layer.cornerRadius = goBackButton.frame.height/2
            goBackButton.layer.masksToBounds = true
        }
    }
    
    
    var ref: DatabaseReference!
    var authUser = Auth.auth().currentUser
    var currentUserID : String = ""
    var currentUser : User?
    var matchedUsers : [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        getCurrentUserAndMatchUpdates()
        navigationBarHidden()
    }
    
    func getCurrentUserAndMatchUpdates() {
        User.generateCurrentUser { (user) in
            if let validUser = user as? User {
                self.currentUser = validUser
                
                guard let matches = self.currentUser?.matches else {return}
                self.fetchMatches(matches)
                
                
            }
        }
    }
    
    func fetchMatches(_ matches: [String]) {
        matchedUsers = []
        
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            
            guard let userDict = snapshot.value as? [String:Any] else {return}
            
            for any in matches {
                if any == snapshot.key {
                    
                    if let name = userDict["userName"] as? String,
                        let id = userDict["id"] as? String,
                        let gender = userDict["gender"] as? String,
                        let preference = userDict["preference"] as? String,
                        let picURLs = userDict["pictureArray"] as? [String],
                        let bio = userDict["bio"] as? String {
                    
                    let user = User(anID: id, aName: name, aGender: gender, aPreference: preference, aPictureArray: picURLs, aBio: bio)
                        
                        self.matchedUsers.append(user)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.matchesTableView.reloadData()
            }
        })
        
        
    }
    
    
    func goBackButtonTapped() {
        dismiss(animated: true, completion: nil)  
    }


}

extension MatchesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchedUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MatchTableViewCell.cellIdentifier) as? MatchTableViewCell else {return UITableViewCell()}
        
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: matchedUsers[indexPath.row].pictureArray.first!)
        cell.userNameLabel.text = matchedUsers[indexPath.row].name
        
        
        return cell
    }
}

extension MatchesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}

        //controller.currentUser
        controller.profileType = .matchedProfile
        controller.selectedUser = matchedUsers[indexPath.row]
        
        //present(controller, animated: true, completion: nil)
        navigationController?.pushViewController(controller, animated: true)
        
        
    }
}

