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
        
        let values = ["uid": uid,
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
            DB_REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values, withCompletionBlock: completion)
        }
        
        
    }
    
    func fetchTweets(completion: @escaping ([Tweet])->()) {
        var tweets = [Tweet]()

        DB_REF_TWEETS.observe(.childAdded) { data in
            guard let dictionary = data.value as? [String: Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            let tweetId = data.key

            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweetId , dictionary: dictionary)
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
    
    func fetchReplies(tweet: Tweet, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF_TWEET_REPLIES.child(tweet.tweetId).observe(.childAdded) { data in
            guard let dictionary = data.value as? [String: Any] else {return}
            guard let uid = dictionary["uid"] as? String else {return}
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetId: tweet.tweetId, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
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

