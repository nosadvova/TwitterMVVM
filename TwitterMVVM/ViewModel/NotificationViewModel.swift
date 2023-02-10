//
//  NotificationViewModel.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 09.02.2023.
//

import UIKit

struct NotificationViewModel {
    private let notification: Notification
    private let type: NotificationType
    private let user: User
    
    var notificationMessage: String {
        switch type {
        case .follow:
            return " started following you"
        case .like:
            return " liked one of your tweets"
        case .reply:
            return " replied to yout tweet"
        case .retweet:
            return " retweeted your tweet"
        case .mention:
            return " mentioned you"
        }
    }
    
    var userImageUrl: URL? {
        return user.userImageUrl
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        
        return formatter.string(from: notification.timestamp, to: now) ?? "2s"
    }
    
    var notificationText: NSAttributedString? {
        guard let timestamp = timestampString else {return nil}
        let attributedTitle = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedTitle.append(NSMutableAttributedString(string: notificationMessage,attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedTitle.append(NSMutableAttributedString(string: "  \(timestamp)",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.systemGray]))
        
        return attributedTitle
    }
    
    var hideFollowButton: Bool {
        return type != .follow
    }
    
    var followButtonText: String {
        return user.isFollowed ? "Following" : "Follow"
    }
    
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
