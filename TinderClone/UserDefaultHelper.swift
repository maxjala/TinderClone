//
//  UserDefaultHelper.swift
//  TinderClone
//
//  Created by Max Jala on 27/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static func saveUserID(_ id: String) {
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.set(id, forKey: "userID")
    }
    
    static func getUserID() -> String? {
        let id = UserDefaults.standard.value(forKey: "userID") as? String
        return id
    }
    
    
    //MARK: USER DEFAULTS FOR CURRENT USER GENDER PREFERENCE
    
    static func saveGenderPreference(_ preference: String) {
        UserDefaults.standard.removeObject(forKey: "genderPreference")
        UserDefaults.standard.set(preference, forKey: "genderPreference")
    }
    
    static func getGenderPreference() -> String? {
        let preference = UserDefaults.standard.value(forKey: "genderPreference") as? String
        return preference
    }
    
    //MARK: USER DEFAULTS FOR CURRENT USER GENDER
    
    static func saveUserGender(_ gender: String) {
        UserDefaults.standard.removeObject(forKey: "userGender")
        UserDefaults.standard.set(gender, forKey: "userGender")
    }
    
    static func getUserGender() -> String? {
        let preference = UserDefaults.standard.value(forKey: "userGender") as? String
        return preference
    }
    //MARK: USER DEFAULTS FOR CURRENT USER NAME
    
    static func saveUserName(_ name: String) {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.set(name, forKey: "userName")
    }
    
    static func getUserName() -> String? {
        let name = UserDefaults.standard.value(forKey: "userName") as? String
        return name
    }
    
    //MARK: USER DEFAULTS FOR CURRENT USER LIKES
    
    static func saveUserLikes(_ likedUserIDs: [String]) {
        UserDefaults.standard.removeObject(forKey: "likedUserIDs")
        UserDefaults.standard.set(likedUserIDs, forKey: "likedUserIDs")
    }
    
    static func getUserLikes() -> [String]? {
        let likes = UserDefaults.standard.stringArray(forKey: "likedUserIDs")
        return likes
    }
    
    static func updateUserLikes(_ newLike: String) -> [String]? {
        var likes = UserDefaults.standard.stringArray(forKey: "likedUserIDs")
        likes?.append(newLike)
        UserDefaults.standard.removeObject(forKey: "likedUserIDs")
        UserDefaults.standard.set(likes, forKey: "likedUserIDs")
        
        return likes
    }
    
    //MARK: USER DEFAULTS FOR CURRENT USER PICS
    
    static func saveUserPicURLs(_ likedUserIDs: [String]) {
        UserDefaults.standard.removeObject(forKey: "picURLS")
        UserDefaults.standard.set(likedUserIDs, forKey: "picURLS")
    }
    
    static func getUserImageURLs() -> [String]? {
        let picURLs = UserDefaults.standard.stringArray(forKey: "picURLS")
        return picURLs
    }
    
    static func updateUserPicURLs(_ newLike: String) -> [String]? {
        var urls = UserDefaults.standard.stringArray(forKey: "picURLS")
        urls?.append(newLike)
        UserDefaults.standard.removeObject(forKey: "picURLS")
        UserDefaults.standard.set(urls, forKey: "picURLS")
        
        return urls
    }
    
    static func saveUserMatches(_ matchedUserID: [String]) {
        UserDefaults.standard.removeObject(forKey: "userMatches")
        UserDefaults.standard.set(matchedUserID, forKey: "userMatches")
    }
    
    static func getUserMatches() -> [String]? {
        let matches = UserDefaults.standard.stringArray(forKey: "userMatches")
        return matches
    }
    
    static func updateUserMatches(_ newMatch: String) -> [String]? {
        var match = UserDefaults.standard.stringArray(forKey: "userMatches")
        match?.append(newMatch)
        UserDefaults.standard.removeObject(forKey: "userMatches")
        UserDefaults.standard.set(match, forKey: "userMatches")
        
        return match
    }
    
}
