//
//  FacebookLogin.swift
//  TinderClone
//
//  Created by Max Jala on 29/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import Firebase

extension LoginViewController : FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        handleLogin()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
    func handleLogin() {
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else {return}
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("Something wrong with error user ", error!)
                return
            }
            
            var ref: DatabaseReference!
            let userAuth = Auth.auth().currentUser
            var currentUserID : String = ""
            //var currentUser : User?
            
            ref = Database.database().reference()
            
            if let id = userAuth?.uid {
                print(id)
                currentUserID = id
                
                var likeArray : [String] = []
                var matchArray : [String] = []
                //var superLikeArray : [String] = []
                
                ref.child("users").child(currentUserID).observe(.value, with: { (snapshot) in
                    print("Value : " , snapshot)
                    
                    let id = snapshot.key
                    if let userDetails = snapshot.value as? [String:Any],
                        let name = userDetails["userName"] as? String,
                        let gender = userDetails["gender"] as? String,
                        let preference = userDetails["preference"] as? String,
                        let picURLs = userDetails["pictureArray"] as? [String],
                        let bio = userDetails["bio"] as? String {
                        
                        if let likeDict = userDetails["liked"] as? [String:Any] {
                            likeArray = Array(likeDict.keys)
                        }
                        
                        if let matchDict = userDetails["matches"] as? [String:Any] {
                            matchArray = Array(matchDict.keys)
                        }
                        
                        let currentUser = User(anID: id, aName: name, aGender: gender, aPreference: preference, aPictureArray: picURLs, aBio: bio)
                        currentUser.likedPeople = likeArray
                        currentUser.matches = matchArray
                        
                        UserDefaults.saveUserID(currentUser.id)
                        UserDefaults.saveGenderPreference(currentUser.preference)
                        UserDefaults.saveUserGender(currentUser.gender)
                        UserDefaults.saveUserName(currentUser.name)
                        UserDefaults.saveUserLikes(currentUser.likedPeople)
                        UserDefaults.saveUserMatches(matchArray)
                        
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let viewController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                        //viewController.currentUser
                        
                        self.present(viewController, animated: true, completion: nil)
                    } else {
                        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email, birthday, age_range, location, gender, work"]).start { (completion, result, err) in
                            if err != nil {
                                print("Failed to graph request", err!)
                                return
                            }
                            
                            if let dictionary = result as? [String : Any] {
                                
                                let fbUserName = user!.displayName
                                let fbUserPhotoUrl = "\((user!.photoURL)!)"
                                let fbUserGender = dictionary["gender"] as? String
                                let fbUserEmail = dictionary["email"] as? String
                                guard let FBvalues : [String : Any] = ["userName" : fbUserName, "id" : user?.uid, "pictureArray" : [fbUserPhotoUrl], "email" : fbUserEmail] else {return}
                                Database.database().reference().child("users").child((user?.uid)!).updateChildValues(FBvalues)
                                
                                let newUser = User(anID: (user?.uid)!, aName: fbUserName!, aGender: "Default", aPreference: "Default", aPictureArray: [fbUserPhotoUrl], aBio: "")
                               
                                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                let viewController = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
                                viewController.currentUser = newUser
                                viewController.userPicURLArray = newUser.pictureArray
                                
                                self.present(viewController, animated: true, completion: nil)

                                
                            }
                            
                        }

                        
                    }
                })
                
            }
            
            print("Successfully logged in ", user!)
        })
        
    }
    
}
