//
//  TestViewController.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TestViewController: UIViewController {

    let cardView1 = Bundle.main.loadNibNamed("ProfileCardView", owner: self, options: nil)?.first as? ProfileCardView
    let cardView2 = Bundle.main.loadNibNamed("ProfileCardView", owner: self, options: nil)?.first as? ProfileCardView
    
    var ref: DatabaseReference!
    //var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var preferredUsers : [User] = []
    
    var currentUser : User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpCardViews()
        
        fetchPreferedGender()
        
    }
    
    func setUpCardViews() {
        cardView1?.center.y = view.frame.height/2
        cardView1?.center.x = view.frame.width/2
        cardView1?.frame.size = CGSize(width: 375, height: 455)
        
        //cardView1?.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 375, height: 455)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(TestViewController.handleSwipe(_:)))
        cardView1?.addGestureRecognizer(panGesture)
        
        self.view.addSubview(cardView1!)
        
        cardView2?.center.y = view.frame.height/2
        cardView2?.center.x = view.frame.width/2
        //cardView2?.frame = CGRect(x: view.frame.width/2, y: view.frame.height/2, width: 375, height: 455)
        cardView1?.frame.size = CGSize(width: 375, height: 455)
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(TestViewController.handleSwipe2(_:)))
        cardView2?.addGestureRecognizer(panGesture2)
        
        view.addSubview(cardView2!)
        view.addSubview(cardView1!)

    }

    
    func fetchPreferedGender() {
        preferredUsers = []
        
        let genderPreference = UserDefaults.getGenderPreference()
        let userGender = UserDefaults.getUserGender()
        
        if genderPreference != nil && userGender != nil {
            User.fetchAGender(userGender: userGender!, userPreference: genderPreference!) { (user) in
                self.preferredUsers.append(user)
                
                
                if self.preferredUsers.count > 1 {
                    
                    self.cardView1?.isHidden = false
                    self.cardView2?.isHidden = false
                    
                    self.setUpCard(self.cardView1!, with: self.preferredUsers[0])
                    self.setUpCard(self.cardView2!, with: self.preferredUsers[1])
                } else if self.preferredUsers.count == 1 {
                    
                    self.cardView1?.isHidden = false
                    self.setUpCard(self.cardView1!, with: self.preferredUsers[0])
                } else {
                    self.cardView1?.isHidden = true
                    self.cardView2?.isHidden = true
                }
                
            }
        }
        
    }
    
    func setUpCard(_ card: ProfileCardView, with user: User) {
        card.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profilePicURL)
        
        let detailString = "\(user.name), \(user.age)"
        card.nameLabel.text = detailString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func handleSwipe(_ sender: UIPanGestureRecognizer) {
        preferredUsers = TestSwipeGestureHelper.handleSwipe2(sender, superView: view, cardView: cardView1!, fetchedUsers: preferredUsers)!
    }
    
    func handleSwipe2(_ sender: UIPanGestureRecognizer) {
        preferredUsers = TestSwipeGestureHelper.handleSwipe2(sender, superView: view, cardView: cardView2!, fetchedUsers: preferredUsers)!
    }

}
