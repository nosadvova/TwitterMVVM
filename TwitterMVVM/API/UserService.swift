//
//  UserService.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 01.02.2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

struct UserService {
    
    static let shared = UserService()
    
    func fetchUser(uid: String ,completion: @escaping (User) -> ()) {
        
        DB_REF_USERS.child(uid).observeSingleEvent(of: .value) { data in
            guard let dictionary = data.value as? [String: AnyObject] else {return}
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchUser(completion: @escaping ([User]) -> ()) {
        var users = [User]()
        
        DB_REF_USERS.observe(.childAdded, with: { data in
            let uid = data.key
            guard let dictionary = data.value as? [String: AnyObject] else {return}
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        })
    }
    
    func followUser(uid: String, completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_USER_FOLLOWING.child(currentUid).updateChildValues([uid: 1]) { error, reference in
            DB_REF_USER_FOLLOWERS.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_USER_FOLLOWING.child(currentUid).child(uid).removeValue { error, reference in
            DB_REF_USER_FOLLOWERS.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_USER_FOLLOWING.child(currentUid).child(uid).observeSingleEvent(of: .value) { data in
            completion(data.exists())
        }
    }
    
    func fetchUsersStats(uid: String, completion: @escaping (UserRelationStats) -> ()) {
        DB_REF_USER_FOLLOWERS.child(uid).observeSingleEvent(of: .value) { data in
            let followers = data.children.allObjects.count
            
            DB_REF_USER_FOLLOWING.child(uid).observeSingleEvent(of: .value) { data in
                let following = data.children.allObjects.count
                let stats = UserRelationStats(followers: followers, following: following)
                completion(stats)
            }
        }
    }
}
