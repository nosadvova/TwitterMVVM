//
//  User.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 01.02.2023.
//

import Foundation

struct User {
    let email: String
    let fullname: String
    let username: String
    let userImageUrl: String
    let uid: String
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullName"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.userImageUrl = dictionary["userImageUrl"] as? String ?? ""
        
        self.uid = uid
    }
    
}
