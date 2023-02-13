//
//  User.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 01.02.2023.
//

import Foundation
import FirebaseAuth

struct User {
    let email: String
    var fullname: String
    var username: String
    var userImageUrl: URL?
    let uid: String
    var userStats: UserRelationStats?
    var bio: String?
    
    var isFollowed = false
    
    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""        
        self.uid = uid
        
        if let bio = dictionary["bio"] as? String {
            self.bio = bio
        }
        
        if let userImageUrlString = dictionary["userImageUrl"] as? String {
            guard let url = URL(string: userImageUrlString) else {return}
            self.userImageUrl = url
        }
        
        
    }
    
}

struct UserRelationStats {
    var followers: Int
    var following: Int
}
