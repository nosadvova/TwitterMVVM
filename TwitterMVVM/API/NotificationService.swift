//
//  NotificationService.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 09.02.2023.
//

import Foundation
import FirebaseAuth

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(type: NotificationType, tweet: Tweet? = nil, user: User? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        
        if let tweet = tweet {
            values["tweetId"] = tweet.tweetId
            DB_REF_NOTIFICATIONS.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let user = user {
            DB_REF_NOTIFICATIONS.child(user.uid).childByAutoId().updateChildValues(values)
        }
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> ()) {
        var notifications = [Notification]()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_NOTIFICATIONS.child(uid).observe(.childAdded) { data in
            guard let dictionary = data.value as? [String: AnyObject] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
}
