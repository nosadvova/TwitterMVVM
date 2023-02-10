//
//  HeaderViewModel.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 04.02.2023.
//

import UIKit

enum ProfileCategoryOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
    var description: String {
        switch self {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
}

struct ProfileHeaderViewModel {
    
    private let user: User
    
    var followers: NSAttributedString? {
        return attributedText(value: user.userStats?.followers ?? 0, text: " followers ")
    }
    
    var following: NSAttributedString? {
        return attributedText(value: user.userStats?.following ?? 0, text: " following")
    }
    
    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit profile"
        }
        
        if !user.isFollowed && !user.isCurrentUser {
            return "Follow"
        }
        
        if user.isFollowed {
            return "Unfollow"
        }
        
        return "Loading"
    }
    
    let usernameText: String
    
    init(user: User) {
        self.user = user
        
        self.usernameText = "@" + user.username
    }
    
    fileprivate func attributedText(value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: String(value), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSMutableAttributedString(string: text,attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.systemGray]))
            
        return attributedTitle
    }
}
