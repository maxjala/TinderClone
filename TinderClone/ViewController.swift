//
//  ViewController.swift
//  TinderClone
//
//  Created by Max Jala on 26/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            profileImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var nopeImageView: UIImageView!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var cardView: UIView! {
        didSet {
            cardView.isHidden = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            cardView.addGestureRecognizer(tapGesture)
            
        }
    }
    
    @IBOutlet weak var superLikeView: UIStackView! {
        didSet {
            superLikeView.isHidden = true
        }
    }
    
    
    @IBOutlet weak var like2ImageView: UIImageView!
    
    @IBOutlet weak var nope2ImageView: UIImageView!
    
    @IBOutlet weak var nameAgeLabel: UILabel!
    
    
    
    @IBOutlet weak var profile2ImageView: UIImageView! {
        didSet{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            profile2ImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var card2View: UIView! {
        didSet {
            card2View.isHidden = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            card2View.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var nameAgeLabel2: UILabel!
    
    @IBOutlet weak var superLikeView2: UIStackView! {
        didSet {
            superLikeView2.isHidden = true
        }
    }
    
    
    
    @IBOutlet weak var resetButton: UIButton! {
        didSet{
            resetButton.addTarget(self, action: #selector(resetCard), for: .touchUpInside)
        }
    }
    
    var ref: DatabaseReference!
    //var currentUser : FIRUser? = FIRAuth.auth()?.currentUser
    var preferredUsers : [User] = []
    
    var currentUser : User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPreferedGender()
        navigationBarClear()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    func fetchPreferedGender() {
        preferredUsers = []
        
        let genderPreference = UserDefaults.getGenderPreference()
        let userGender = UserDefaults.getUserGender()
        
        if genderPreference != nil && userGender != nil {
            User.fetchAGender(userGender: userGender!, userPreference: genderPreference!) { (user) in
                self.preferredUsers.append(user)

                if self.preferredUsers.count > 1 {
                    self.setUpCardUI(self.preferredUsers[0], profileImageView: self.profile2ImageView, nameAgeLabel: self.nameAgeLabel2, cardView: self.card2View, superLikeView: self.superLikeView2)
                    self.setUpCardUI(self.preferredUsers[1], profileImageView: self.profileImageView, nameAgeLabel: self.nameAgeLabel, cardView: self.cardView, superLikeView: self.superLikeView)
                    
                } else if self.preferredUsers.count == 1 {
                    self.setUpCardUI(self.preferredUsers[0], profileImageView: self.profile2ImageView, nameAgeLabel: self.nameAgeLabel2, cardView: self.card2View, superLikeView: self.superLikeView2)
                }
            }
        }

    }
    
    func setUpCardUI(_ user: User, profileImageView: UIImageView, nameAgeLabel: UILabel, cardView: UIView, superLikeView: UIStackView) {
        cardView.isHidden = false
        var formattedString = ""
        superLikeView.isHidden = !user.superLiked
        
        profileImageView.loadImageUsingCacheWithUrlString(urlString: user.pictureArray.first!)
        formattedString = "\(user.name), \(user.age)"
        nameAgeLabel.text = formattedString
    }
    
    @IBAction func handleSwipe(_ sender: UIPanGestureRecognizer) {
        preferredUsers = SwipeGestureHelper.handleSwipe(sender, superView: view, likeImageView: likeImageView, nopeImageView: nopeImageView, profileView: profileImageView, nameAgeLabel: nameAgeLabel, fetchedUsers: preferredUsers)!
    }
    
    @IBAction func handleSwipe2(_ sender: UIPanGestureRecognizer) {
        preferredUsers = SwipeGestureHelper.handleSwipe(sender, superView: view, likeImageView: like2ImageView, nopeImageView: nope2ImageView, profileView: profile2ImageView, nameAgeLabel: nameAgeLabel2, fetchedUsers: preferredUsers)!
    }
    
    
    func resetCard() {
        fetchPreferedGender()
    }
    
    func imageTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
        vc.currentUser = preferredUsers[0]
        vc.profileType = .otherProfile
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func matchesButtonTapped(_ sender: UIBarButtonItem) {
        
        
    }
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {return}
        //vc.currentUser = preferredUsers[0]
        vc.profileType = .myProfile
        navigationController?.pushViewController(vc, animated: true)
        
        
        
    }
    
    
    
    
    
    @IBAction func tempLogoutButton(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            let storybord = UIStoryboard(name: "LoginStoryboard", bundle: Bundle.main)
            let logInVC = storybord.instantiateViewController(withIdentifier: "AuthNavigationController")
            present(logInVC, animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
 
    }
    

    


}

