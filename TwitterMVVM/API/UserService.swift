//
//  UserService.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 01.02.2023.
//

import Foundation
import FirebaseAuth

struct UserService {
    
    static let shared = UserService()
    
    func fetchUser() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_USERS.child(uid).observeSingleEvent(of: .value) { data in
            guard let dictionary = data.value as? [String: AnyObject] else {return}
            
            let user = User(uid: uid, dictionary: dictionary)
            print(user)
        }
        
    }
}
