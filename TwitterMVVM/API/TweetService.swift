//
//  TweetService.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 02.02.2023.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase


struct TweetService {
    static let shared = TweetService()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        var values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String : Any]
        
        switch type {
        case .tweet:
            DB_REF_TWEETS.childByAutoId().updateChildValues(values) { error, reference in
                guard let tweetId = reference.key else {return}
                DB_REF_USER_TWEETS.child(uid).updateChildValues([tweetId: 1], withCompletionBlock: completion)
            }
            
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            
            DB_REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values) { error, reference in
                guard let replyKey = reference.key else {return}
                DB_REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetId: replyKey], withCompletionBlock: completion)
            }
        } 
    }
    
    func fetchTweets(completion: @escaping ([Tweet])->()) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        DB_REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { data in
            let followingUid = data.key
            DB_REF_USER_TWEETS.child(followingUid).observe(.childAdded) { data in
                let tweetId = data.key
                
                self.fetchTweet(tweetId: tweetId) { tweet in
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        
        DB_REF_USER_TWEETS.child(currentUid).observe(.childAdded) { data in
            let tweetId = data.key
            
            self.fetchTweet(tweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(user: User, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF_USER_TWEETS.child(user.uid).observe(.childAdded) { data in
            let tweetId = data.key
            
            self.fetchTweet(tweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(tweetId: String, completion: @escaping (Tweet) -> ()) {
        
        DB_REF_TWEETS.child(tweetId).observeSingleEvent(of: .value, with: { data in
            guard let dictionary = data.value as? [String: Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweetId , dictionary: dictionary)
                completion(tweet)
            }
        })
    }
    
    func fetchLikes(user: User, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF_USER_LIKES.child(user.uid).observe(.childAdded) { data in
            let tweetId = data.key
            
            self.fetchTweet(tweetId: tweetId) { tweet in
                var tweet = tweet
                tweet.isLiked = true
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchReplies(tweet: Tweet, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF_TWEET_REPLIES.child(tweet.tweetId).observe(.childAdded) { data in
            guard let dictionary = data.value as? [String: Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            
            UserService.shared.fetchUser(uid: uid) { user in
                let reply = Tweet(user: user, tweetId: tweet.tweetId, dictionary: dictionary)
                tweets.append(reply)
                completion(tweets)
            }
        }
    }
    
    func fetchRepliesForUser(user: User, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF_USER_REPLIES.child(user.uid).observe(.childAdded) { data in
            let tweetKey = data.key
            guard let replyKey = data.value as? String else {return}
            
            DB_REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { data in
                guard let dictionary = data.value as? [String: Any] else {return}
                guard let uid = dictionary["uid"] as? String else {return}
                let replyId = data.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetId: replyId, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let likes = tweet.isLiked ? tweet.likes - 1 : tweet.likes + 1
        
        DB_REF_TWEETS.child(tweet.tweetId).child("likes").setValue(likes)
        
        if tweet.isLiked {
            DB_REF_USER_LIKES.child(uid).child(tweet.tweetId).removeValue { error, reference in
                DB_REF_TWEET_LIKES.child(tweet.tweetId).removeValue(completionBlock: completion)
            }
        } else {
            DB_REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetId: 1]) { error, reference in
                DB_REF_TWEET_LIKES.child(tweet.tweetId).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedTweet(tweet: Tweet, completion: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {return}

        DB_REF_USER_LIKES.child(uid).child(tweet.tweetId).observeSingleEvent(of: .value) { data in
            completion(data.exists())
        }
    }
}

