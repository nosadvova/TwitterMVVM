//
//  TweetVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 06.02.2023.
//

import UIKit

private let headerIdentifier = "tweetHeader"
private let cellIdentifier = "cell"

class TweetVC: UICollectionViewController {
    
    //MARK: - Properties
    
    private let tweet: Tweet
    private var sheetLauncher: ActionSheetLauncher!
    var replies = [Tweet]() {
        didSet{collectionView.reloadData()}
    }
    
    //MARK: - Lifecycle
    
    init(tweet: Tweet) {
        self.tweet = tweet
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - API
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(tweet: tweet) { replies in
            self.replies = replies
        }
    }
    
    //MARK: - Selectors
    
    //MARK: - Functionality
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    fileprivate func showActionSheet(_ user: User) {
        sheetLauncher = ActionSheetLauncher(user: user)
        sheetLauncher.delegate = self
        sheetLauncher.show()
    }
}

//MARK: - UICollectionViewDataSource

extension TweetVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        
        return cell
    }
}

//MARK: - Header implementaition

extension TweetVC {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TweetHeader
        header.delegate = self
        header.tweet = tweet
        
        return header
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension TweetVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.tweetSize(width: view.frame.width).height
        return CGSize(width: view.frame.width, height: captionHeight + 265)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

//MARK: - TweetHeaderDelegate

extension TweetVC: TweetHeaderDelegate {    
    func fetchUser(username: String) {
        UserService.shared.fetchUser(user: username) { user in
            let vc = UserProfileVC(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func actionSheet() {
        var user = self.tweet.user
        if tweet.user.isCurrentUser {
            showActionSheet(user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
                user.isFollowed = isFollowed
                self.showActionSheet(user)
            }
        }
    }
}

//MARK: - ActionSheetLauncherDelegate

extension TweetVC: ActionSheetLauncherDelegate {
    func didSelectOption(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { error, reference in
                
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { error, reference in
                
            }
        case .report:
            print("Report")
        case .delete:
            print("Delete")
        }
    }
}

