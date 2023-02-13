//
//  UserProfileVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "tweetCell"
private let headerIdentifier = "headerView"

class UserProfileVC: UICollectionViewController {
    
    //MARK: - Properties
    
    private var user: User
    
    private var selectedCategory: ProfileCategoryOptions = .tweets {
        didSet {collectionView.reloadData()}
    }
    
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var repliedTweets = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedCategory {
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
        fetchReplies()
        fetchLikedTweets()
        fetchUsersStats()
        
        checkIfUserFollowed()
    }
    
    //MARK: - API
    
    func fetchLikedTweets() {
        TweetService.shared.fetchLikes(user: user) { tweets in
            self.likedTweets = tweets
        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchRepliesForUser(user: user) { tweets in
            self.repliedTweets = tweets
        }
    }
    
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
    
    //MARK: - Functionality
    
    func configureUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.backgroundColor = .white
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else {return}
        collectionView.contentInset.bottom = tabHeight
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetVC(tweet: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        var height: CGFloat = 300

        if user.bio == nil {
            height -= 15
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.tweetSize(width: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            height += 25
        }
        return CGSize(width: view.frame.width, height: height)
    }
}

//MARK: - ProfileHeaderDelegate

extension UserProfileVC: ProfileHeaderDelegate {
    func didSelectCategory(category: ProfileCategoryOptions) {
        self.selectedCategory = category
    }
    
    func editProfileFollowUserTapped(header: ProfileHeader) {
        if user.isCurrentUser {
            let vc = EditProfileVC(user: user)
            let nav = UINavigationController(rootViewController: vc)
            
            vc.delegate = self

            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
            return
        }
                    
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

//MARK: - EditProfileControllerDelegate

extension UserProfileVC: EditProfileControllerDelegate {
    func handleLogOut() {
        do {
           try Auth.auth().signOut()
            let nav = UINavigationController(rootViewController: LoginVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        } catch {
            print("logOut() error")
        }
    }
    
    func controller(controller: EditProfileVC, updateUser: User) {
        controller.dismiss(animated: true)
        self.user = updateUser
        self.collectionView.reloadData()
    }
    
    
}
