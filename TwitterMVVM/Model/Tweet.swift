//
//  Tweet.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 02.02.2023.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetId: String
    var likes: Int
    var retweets: Int
    var timestamp: Date!
    var replyingTo: String?
    
    var isLiked = false
    var user: User
    
    var isReply: Bool {
        return replyingTo != nil
    }
    
    init(user: User, tweetId: String, dictionary: [String: Any]) {
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        
        self.user = user
        self.tweetId = tweetId
        
        
    }
}
