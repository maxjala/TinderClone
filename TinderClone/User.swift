//
//  Users.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var id : String = ""
    var name : String = ""
    var age : Int = 0
    var birthdate : Int = 0
    var gender : String = ""
    var preference : String = ""
    var profilePicURL : String = ""
    var bio : String = ""
    var pictureArray : [String] = []
    var likedPeople : [String] = []
    var superLiked = false
    var matches : [String] = []
    
    init(anID: String, aName: String, aGender: String, aPreference: String, aPictureArray: [String], aBio: String) {
        id = anID
        name = aName
        gender = aGender
        preference = aPreference
        pictureArray = aPictureArray
        bio = aBio
        
    }
    
    static func generateCurrentUser(completion: @escaping(_ completed:User)->Swift.Void) {
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
                    
                    
                    completion(currentUser)
                }
            })
            
        }
    }
    
    
    
    static func fetchAGender(userGender: String, userPreference: String, completion: @escaping(_ completed:User)->Swift.Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        //var currentUserID : String = ""

        
        ref.child("users").observe(.childAdded, with: { (snapshot) in
            print("Value : " , snapshot)
            
            guard let user = snapshot.value as? [String:Any]
                else {
                    print("snapshot casted incorrectly")
                    return
            }
            
            if let alreadyLikedUsers = UserDefaults.getUserLikes() {
                for any in alreadyLikedUsers {
                    if any == snapshot.key {
                        return
                    }
                }
            }
            
            if currentUser?.uid == snapshot.key {
                return
            }
            
            //check selected user preferencee
            //if user["preference"] as? String == "Both" && user["gender"] as? String == userPreference  {
            if userPreference == "Both" {
                
                if let name = user["userName"] as? String,
                    let id = user["id"] as? String,
                    let gender = user["gender"] as? String,
                    let preference = user["preference"] as? String,
                    let picURLs = user["pictureArray"] as? [String],
                    let bio = user["bio"] as? String {
                    
                    let newUser = User(anID: id, aName: name, aGender: gender, aPreference: preference, aPictureArray: picURLs, aBio: bio)
                    
                    if let superLikeDict = user["superLiked"] as? [String:Any] {
                        let superLikeArray = Array(superLikeDict.keys)
                        
                        for any in superLikeArray {
                            if any == currentUser?.uid {
                                newUser.superLiked = true
                            }
                        }
                    }

                    completion(newUser)
                    return
                    
                }
            }
            

            if user["gender"] as? String == userPreference  {

                if let name = user["userName"] as? String,
                    let id = user["id"] as? String,
                    let gender = user["gender"] as? String,
                    let preference = user["preference"] as? String,
                    let picURLs = user["pictureArray"] as? [String],
                    let bio = user["bio"] as? String {
                    
                    let newUser = User(anID: id, aName: name, aGender: gender, aPreference: preference, aPictureArray: picURLs, aBio: bio)
                    
                    if let superLikeDict = user["superLiked"] as? [String:Any] {
                        let superLikeArray = Array(superLikeDict.keys)
                        
                        for any in superLikeArray {
                            if any == currentUser?.uid {
                                newUser.superLiked = true
                            }
                        }
                    }
                    
                    //returnedUser.append(newUser)
                    
                    completion(newUser)
                    return
                    
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
