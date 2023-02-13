//
//  TweetViewModel.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit

struct TweetViewModel {
    
    //MARK: - Properties
    
    let tweet: Tweet
    let user: User
    
    var userImageUrl: URL? {
        return user.userImageUrl
    }
    
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        return formatter.string(from: tweet.timestamp, to: now) ?? "2s"
    }
    
    var usernameText: String {
        return "@\(user.username)"
    }
    
    var timestampText: String {
        let dateFromatter = DateFormatter()
        
        dateFromatter.dateFormat = "h:mm a • MM/dd/yyyy"
        return dateFromatter.string(from: tweet.timestamp)
    }
    
    var retweetsAttributedString: NSAttributedString? {
        return attributedText(value: tweet.retweets, text: " retweets")
    }
    
    var likesAttributedString: NSAttributedString? {
        return attributedText(value: tweet.likes, text: " likes")
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        title.append(NSAttributedString(string: " @\(user.username) • \(timestamp)",
                                        attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return title
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.isLiked ? .red : .darkGray
    }
    
    var likeButtonImage: UIImage {
        let image = tweet.isLiked ? "like_filled" : "like"
        return UIImage(named: image)!
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }
    
    var replyText: String? {
        guard let replyingToString = tweet.replyingTo else {return nil}
        return "↩︎ replying to \(replyingToString)"
    }
    
    //MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
    
    //MARK: - Functionality
    
    fileprivate func attributedText(value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: String(value), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSMutableAttributedString(string: text,attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemGray]))
            
        return attributedTitle
    }
    
    func tweetSize(width: CGFloat) -> CGSize {
        let label = UILabel()
        label.text = tweet.caption
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
