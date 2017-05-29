//
//  TestSwipeGestureHelper.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation
import UIKit

class TestSwipeGestureHelper {
    
    static func handleSwipe2(_ sender: UIPanGestureRecognizer, superView: UIView!, cardView: ProfileCardView, fetchedUsers: [User]) -> [User]? {
        
        let divider = (superView.frame.width / 2) / 0.61 //0.61 is radian value of 35 degree
        let card = sender.view!
        let point = sender.translation(in: superView)
        let xFromCenter = card.center.x - superView.center.x
        //let scale = min(abs(100 / xFromCenter) , 1) //  min  will return the smallest number after compairing , abs will take the positive value only
        
        card.center = CGPoint(x: superView.center.x + point.x , y: superView.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: xFromCenter/divider).scaledBy(x: 1, y: 1) // for scaling anything less than 1 will make the object smaller
        
        if xFromCenter > 0 {
            cardView.likeImageView.image = #imageLiteral(resourceName: "heart")
            cardView.likeImageView.tintColor = UIColor.green
            cardView.likeImageView.alpha = abs(xFromCenter) / superView.center.x
        }else{
            cardView.nopeImageView.image = #imageLiteral(resourceName: "brokenheart")
            cardView.nopeImageView.tintColor = UIColor.red
            cardView.nopeImageView.alpha = abs(xFromCenter) / superView.center.x
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
                
                
                return hiddenResetCard2(cardView: cardView, superView: superView, fetchedUsers: fetchedUsers)
                
                
            }else if card.center.x > (superView.frame.width - 75){
                // the view should move to the right
                UIView.animate(withDuration: 0.2, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                    //profileView.alpha = 0
                })
                
                return hiddenResetCard2(cardView: cardView, superView: superView, fetchedUsers: fetchedUsers)
                
            }
            resetCard2(cardView: cardView, superView: superView)
            
        }
        
        return fetchedUsers
    }
    
    static func hiddenResetCard2(cardView: ProfileCardView, superView: UIView!, fetchedUsers: [User]) -> [User] {
        
        var userArray = fetchedUsers
        
        cardView.center = superView.center
        cardView.likeImageView.alpha = 0
        cardView.nopeImageView.alpha = 0
        cardView.profileImageView.alpha = 0
        cardView.transform = .identity
        cardView.likeImageView.transform = .identity
        cardView.nopeImageView.transform = .identity
        cardView.profileImageView.transform = .identity
        
        let when = DispatchTime.now() + 0.5
        superView.sendSubview(toBack: cardView)
        
        if userArray.count != 1 {
            userArray.remove(at: 0)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            cardView.alpha = 1
            cardView.profileImageView.alpha = 1
            //profileView.image = picArray[0]
            
            if userArray.count > 1 {
                cardView.profileImageView.loadImageUsingCacheWithUrlString(urlString: userArray[1].profilePicURL)
            } else {
                cardView.isHidden = true
            }
            
        }
        
        
        return userArray
    }
    
    static func resetCard2(cardView: ProfileCardView, superView: UIView!) {
        UIView.animate(withDuration: 0.2) {
            cardView.center = superView.center
            cardView.likeImageView.alpha = 0
            cardView.nopeImageView.alpha = 0
            cardView.alpha = 1
            cardView.transform = .identity
            cardView.likeImageView.transform = .identity
            cardView.nopeImageView.transform = .identity
            cardView.profileImageView.transform = .identity
        }
    }
    
    
}
