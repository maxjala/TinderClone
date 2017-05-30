//
//  SwipeGestureHelper.swift
//  TinderClone
//
//  Created by Max Jala on 26/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class SwipeGestureHelper {

    static func handleSwipe(_ sender: UIPanGestureRecognizer, superView: UIView!, likeImageView: UIImageView, nopeImageView: UIImageView, profileView: UIImageView, nameAgeLabel: UILabel, fetchedUsers: [User]) -> [User]? {
        
        let divider = (superView.frame.width / 2) / 0.61 //0.61 is radian value of 35 degree
        let card = sender.view!
        let point = sender.translation(in: superView)
        let xFromCenter = card.center.x - superView.center.x
        let scale = min(abs(100 / xFromCenter) , 1) //  min  will return the smallest number after compairing , abs will take the positive value only
        
        card.center = CGPoint(x: superView.center.x + point.x , y: superView.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: xFromCenter/divider).scaledBy(x: scale, y: scale) // for scaling anything less than 1 will make the object smaller
        
        if xFromCenter > 0 {
            likeImageView.image = #imageLiteral(resourceName: "heart")
            likeImageView.tintColor = UIColor.green
            likeImageView.alpha = abs(xFromCenter) / superView.center.x
        }else{
            nopeImageView.image = #imageLiteral(resourceName: "brokenheart")
            nopeImageView.tintColor = UIColor.red
            nopeImageView.alpha = abs(xFromCenter) / superView.center.x
        }
        //thumbImageView.alpha = abs(xFromCenter) / view.center.x
        if sender.state == .ended{
            // setting a mergins to 75 to animate
            if card.center.x < 75 {
                // the view should move to the left
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                    //profileView.alpha = 0
                })
                
                return hiddenResetCard(cardView: card, likeView: likeImageView, nopeView: nopeImageView, superView: superView, profileView: profileView, nameAgeLabel: nameAgeLabel, fetchedUsers: fetchedUsers)
                
                
            }else if card.center.x > (superView.frame.width - 75){
                // the view should move to the right
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    //profileView.alpha = 0
                })
                
                like(fetchedUsers[0])
                
                return hiddenResetCard(cardView: card, likeView: likeImageView, nopeView: nopeImageView, superView: superView, profileView: profileView, nameAgeLabel: nameAgeLabel, fetchedUsers: fetchedUsers)
                
            } else if card.center.y < 100 {
                // the view should move to the right
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    //profileView.alpha = 0
                })
                
                superLike(fetchedUsers[0])
                return hiddenResetCard(cardView: card, likeView: likeImageView, nopeView: nopeImageView, superView: superView, profileView: profileView, nameAgeLabel: nameAgeLabel, fetchedUsers: fetchedUsers)
                
            }
            resetCard(cardView: card, superView: superView, likeImageView: likeImageView, nopeImageView: nopeImageView)
            
        }
        
        return fetchedUsers
    }
    
    static func resetCard(cardView: UIView, superView: UIView!, likeImageView: UIImageView, nopeImageView: UIImageView){
        UIView.animate(withDuration: 0.2) {
            cardView.center = superView.center
            likeImageView.alpha = 0
            nopeImageView.alpha = 0
            cardView.alpha = 1
            cardView.transform = .identity
        }
    }
    
    static func hiddenResetCard(cardView: UIView, likeView: UIImageView, nopeView: UIImageView, superView: UIView!, profileView: UIImageView, nameAgeLabel: UILabel, fetchedUsers: [User]) -> [User] {
        
        var userArray = fetchedUsers
        
        cardView.center = superView.center
        likeView.alpha = 0
        nopeView.alpha = 0
        profileView.alpha = 0
        cardView.transform = .identity
        
        //let when = DispatchTime.now() + 0.5
        superView.sendSubview(toBack: cardView)
        
        if userArray.count != 1 {
            userArray.remove(at: 0)
        }
        
        
            cardView.alpha = 1
            profileView.alpha = 1
        //profileView.image = picArray[0]
        
        if userArray.count > 1 {
            profileView.loadImageUsingCacheWithUrlString(urlString: userArray[1].pictureArray[0])
            let formattedString = "\(userArray[1].name), \(userArray[1].age)"
            
            nameAgeLabel.text = formattedString

                cardView.isHidden = false
        } else {
                cardView.isHidden = true
        }
        
        return userArray
    }
    
    static func like(_ user: User) {
        var ref : DatabaseReference!
        let userAuth = Auth.auth().currentUser
        var currentUserID : String = ""
        ref = Database.database().reference()
        
        if let id = userAuth?.uid {
            print(id)
            currentUserID = id
            
            UserDefaults.updateUserLikes(user.id)
            
            
            let like = [user.id: "liked"]
            ref.child("users").child(currentUserID).child("liked").updateChildValues(like)
            
            observeIfLikedCreateMatch(user)
            
        }
        
    }
    
    static func superLike(_ user: User) {
        var ref : DatabaseReference!
        let userAuth = Auth.auth().currentUser
        var currentUserID : String = ""
        ref = Database.database().reference()
        
        if let id = userAuth?.uid {
            print(id)
            currentUserID = id
            
            UserDefaults.updateUserLikes(user.id)
            
            
            let like = [user.id: "liked"]
            let superLike = [user.id: "superLike"]
            ref.child("users").child(currentUserID).child("liked").updateChildValues(like)
            ref.child("users").child(currentUserID).child("superLiked").updateChildValues(superLike)
            
            observeIfLikedCreateMatch(user)
            
        }
        
    }

    
    
    
    static func observeIfLikedCreateMatch(_ likedUser: User) {
        var ref : DatabaseReference!
        let userAuth = Auth.auth().currentUser
        var currentUserID : String = ""
        ref = Database.database().reference()
        
        if let id = userAuth?.uid {
            print(id)
            currentUserID = id
            
            ref.child("users").child(likedUser.id).child("liked").observe(.childAdded, with: { (snapshot) in
                if let liked = snapshot.key as? String {
                    
                    if liked == currentUserID {

                        let matchedIDs = [currentUserID, likedUser.id]

                        let matchID = "\(matchedIDs.sorted()[0])-\(matchedIDs.sorted()[1])"
                        
                        let matchedUsers = ["users": [currentUserID: UserDefaults.getUserName(), likedUser.id: likedUser.name]]
                        
                        let myRefPost = [likedUser.id : "match"]
                        let theirRefPost = [currentUserID : "match"]
                        
                        ref.child("matches").child(matchID).updateChildValues(matchedUsers)
                        ref.child("users").child(currentUserID).child("matches").updateChildValues(myRefPost)
                        ref.child("users").child("\(likedUser.id)").child("matches").updateChildValues(theirRefPost)
                        
                    }
                    return
                }
            })
        }
    }
    
    
    
    
    
    
    
    
}
