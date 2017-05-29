//
//  ProfileViewController.swift
//  TinderClone
//
//  Created by Max Jala on 28/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var editInfoButton: UIButton! {
        didSet {
            editInfoButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            editInfoButton.isHidden = false
        }
    }
    
    @IBOutlet weak var closeVCButton: UIButton! {
        didSet {
            closeVCButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
            closeVCButton.layer.cornerRadius = closeVCButton.frame.width/2
            closeVCButton.layer.masksToBounds = true
        }
    }
    
    
    var currentUser : User?
    
    var profileType : ProfileType = .myProfile
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                    self.currentUser = user
                    self.setUpUI(for: self.currentUser!)
                }
            })
        } else if profileType == .matchedProfile {
            setUpUI(for: currentUser!)
            editInfoButton.isHidden = true
            chatSettingsButton.isHidden = false
        } else {
            setUpUI(for: currentUser!)
            editInfoButton.isHidden = true
        }
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
        
        guard let picArray = currentUser?.pictureArray else {return}
        
        vc.userPicURLArray = picArray
        vc.displayType = .editProfile
        vc.currentUser = currentUser
        
        present(vc, animated: true, completion: nil)

    }
    
    func dismissVC() {
        guard let navVC = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {return}
        //dismiss(animated: true, completion: nil)
    //navigationController?.popToViewController(navVC, animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    func goToChatVC() {
        guard let chatVC = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {return}
        chatVC.matchedUser = currentUser
        
        //present(chatVC, animated: true, completion: nil)
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    
    
}

extension ProfileViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if currentUser != nil {
            return (currentUser?.pictureArray.count)!
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.cellIdentifier, for: indexPath) as! PictureCollectionViewCell
        
        cell.pictureURL = currentUser?.pictureArray[indexPath.item]
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
