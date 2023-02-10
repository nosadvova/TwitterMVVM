//
//  UserProfileVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit

private let reuseIdentifier = "tweetCell"
private let headerIdentifier = "headerView"

class UserProfileVC: UICollectionViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var selectedFilter: ProfileCategoryOptions = .tweets {
        didSet {collectionView.reloadData()}
    }
    
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var repliedTweets = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets:
            return tweets
        case .replies:
            return repliedTweets
        case .likes:
            return likedTweets
        }
    }
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
        fetchUsersStats()
        checkIfUserFollowed()
    }
    
    //MARK: - Functionality
    
    func fetchTweets() {
        TweetService.shared.fetchTweets(user: user) { tweets in
            self.tweets = tweets
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUsersStats() {
        UserService.shared.fetchUsersStats(uid: user.uid) { stats in
            self.user.userStats = stats
            self.collectionView.reloadData()
        }
    }
    
    func configureUI() {
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        view.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isScrollEnabled = true
    }
}

//MARK: - Header implementaition

extension UserProfileVC {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        
        return header
    }
}

// MARK: UICollectionViewDataSource

extension UserProfileVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        
        cell.tweet = currentDataSource[indexPath.row]
                
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

//MARK: - ProfileHeaderDelegate

extension UserProfileVC: ProfileHeaderDelegate {
    func editProfileFollowUserTapped(header: ProfileHeader) {
        guard !user.isCurrentUser else {return}
                    
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { error, reference in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { database, error in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(type: .follow, user: self.user)
            }
        }
    }
    
    func dismissScreen() {
        navigationController?.popViewController(animated: true)
    }
}
