//
//  ProfileViewController.swift
//  TinderClone
//
//  Created by Max Jala on 28/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

enum ProfileType {
    case myProfile
    case unmatchedProfile
    case matchedProfile
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var pictureCollectionView: UICollectionView! {
        didSet{
            pictureCollectionView.dataSource = self
            pictureCollectionView.delegate = self
            pictureCollectionView.register(PictureCollectionViewCell.cellNib, forCellWithReuseIdentifier: PictureCollectionViewCell.cellIdentifier)
        }
    }
    
    @IBOutlet weak var nameAgeLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var chatSettingsButton: UIButton! {
        didSet {
            chatSettingsButton.isHidden = true
            chatSettingsButton.addTarget(self, action: #selector(goToChatVC), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var unmatchButton: UIButton! {
        didSet {
            unmatchButton.addTarget(self, action: #selector(unmatchUserTapped), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var logoutButton: UIButton! {
        didSet {
            logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
            logoutButton.layer.cornerRadius = logoutButton.frame.height/2
            logoutButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var editInfoButton: UIButton! {
        didSet {
            editInfoButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            editInfoButton.isHidden = false
            editInfoButton.layer.cornerRadius = editInfoButton.frame.height/3
            editInfoButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var closeVCButton: UIButton! {
        didSet {
            closeVCButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            closeVCButton.layer.cornerRadius = closeVCButton.frame.width/2
            closeVCButton.layer.masksToBounds = true
        }
    }
    
    
    var selectedUser : User?
    var selectedUserID : String = ""
    var selectedUserName : String = ""
    var profileType : ProfileType = .myProfile
    
    var ref: DatabaseReference!
    var authUser = Auth.auth().currentUser
    var currentUserID : String = ""
    var matchID : String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = Database.database().reference()
        if let id = authUser?.uid {
            currentUserID = id
        }
        
        configureProfileType()
        navigationBarHidden()
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setUpUI()
    }
    
    func configureProfileType() {
        if profileType == .myProfile {
            User.generateCurrentUser(completion: { (user) in
                if user != nil {
                    self.selectedUser = user
                    self.setUpUI(for: self.selectedUser!)
                    self.unmatchButton.isHidden = true
                    
                }
            })
        } else if profileType == .matchedProfile {
            setUpUI(for: selectedUser!)
            editInfoButton.isHidden = true
            chatSettingsButton.isHidden = false
            unmatchButton.isHidden = false
            logoutButton.isHidden = true
            createMatchID()
            
        } else {
            setUpUI(for: selectedUser!)
            editInfoButton.isHidden = true
            self.unmatchButton.isHidden = true
            logoutButton.isHidden = true

        }
    }
    
    func createMatchID() {
        let matchedIDs = [currentUserID, selectedUser?.id]
        //matchID = matchedIDs.sorted(by: <#(String?, String?) -> Bool#>)
        let sortedID = matchedIDs.sorted(by: { (id1, id2) -> Bool in
            id1! < id2!
        })
        
        matchID = "\(String(describing: sortedID[0]))-\(String(describing: sortedID[1]))"
    }

    func setUpUI(for _user: User) {
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width)
        let cellHeight = floor(screenSize.width)
        
        let layout = pictureCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        //pictureCollectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        nameAgeLabel.text = _user.name
        bioLabel.text = _user.bio
        pictureCollectionView.reloadData()
        
    }
    
    func editButtonTapped() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {return}
        
        guard let picArray = selectedUser?.pictureArray else {return}
        
        vc.userPicURLArray = picArray
        vc.displayType = .editProfile
        vc.currentUser = selectedUser
        
        present(vc, animated: true, completion: nil)

    }
    
    func unmatchUserTapped() {
        guard let username = selectedUser?.name else {return}
        
        let alertController = UIAlertController(title: "Unmatch \(username)", message: "Are you sure you want to unmatch \(username)", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Unmatch", style: .destructive, handler: { (alert:UIAlertAction) in
            self.unmatchUser()
            self.dismissVC()
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func unmatchUser() {
        guard let userID = selectedUser?.id else {return}
        
        
        ref.child("users").child(userID).child("matches").child(currentUserID).removeValue()
        ref.child("users").child(userID).child("liked").child(currentUserID).removeValue()
        ref.child("users").child(userID).child("superliked").child(currentUserID).removeValue()
        
        ref.child("users").child(currentUserID).child("matches").child(userID).removeValue()
        ref.child("users").child(currentUserID).child("liked").child(userID).removeValue()
        ref.child("users").child(currentUserID).child("superliked").child(userID).removeValue()
        
        ref.child("matches").child(matchID).removeValue()
        
    }
    
    func dismissVC() {
        guard let navVC = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {return}
        dismiss(animated: true, completion: nil)
        
    }
    
    func goToChatVC() {
        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return}
        chatVC.matchedUser = selectedUser
        
        //present(chatVC, animated: true, completion: nil)
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    func logoutButtonTapped() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            let storybord = UIStoryboard(name: "LoginStoryboard", bundle: Bundle.main)
            let logInVC = storybord.instantiateViewController(withIdentifier: "AuthNavigationController")
            present(logInVC, animated: true, completion: nil)
            
            let facebookLogin = FBSDKLoginManager()
            facebookLogin.logOut()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

    }
    
    
    
}

extension ProfileViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedUser != nil {
            return (selectedUser?.pictureArray.count)!
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.cellIdentifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.pictureURL = selectedUser?.pictureArray[indexPath.item]
        //cell.pictureURL = currentUser?.profilePicURL
        
        return cell
    }
}

extension ProfileViewController : UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let layout = self.pictureCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
    
}
